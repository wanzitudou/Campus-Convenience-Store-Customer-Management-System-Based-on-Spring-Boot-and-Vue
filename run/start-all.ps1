#Requires -Version 5.1
<#
.SYNOPSIS
    一键启动校园小卖部客户管理系统（MySQL + 推荐服务 + 后端 + 前端）

.DESCRIPTION
    按依赖顺序启动四个服务，已启动的会自动跳过。
    只依赖本机免安装工具链（D:\dsh-tools），不需要系统级 JDK / Maven / MySQL。

.PARAMETER Restart
    先停掉已经在跑的服务，再重新启动。

.EXAMPLE
    pwsh -File run\start-all.ps1
    pwsh -File run\start-all.ps1 -Restart
#>
param(
    [switch]$Restart
)

$ErrorActionPreference = 'Continue'

# ---------------------------------------------------------------------------
# 路径与常量
# ---------------------------------------------------------------------------
$Root   = Resolve-Path (Join-Path $PSScriptRoot '..')
$Tools  = 'D:\dsh-tools'
$Jdk    = Join-Path $Tools 'jdk21\jdk-21.0.12.1+1'
$Mysql  = Join-Path $Tools 'mysql\mysql-8.0.28-winx64'
$MysqlData = Join-Path $Tools 'mysql\data'
$Tmp    = Join-Path $Tools 'tmp'
$Logs   = Join-Path $Tools 'logs'

$JavaExe  = Join-Path $Jdk 'bin\java.exe'
$MySqlExe = Join-Path $Mysql 'bin\mysqld.exe'
$Jar      = Join-Path $Root 'springboot\target\springboot-0.0.1-SNAPSHOT.jar'
$PyDir    = Join-Path $Root 'python_recommend'
$VenvPy   = Join-Path $PyDir '.venv\Scripts\python.exe'
$VueDir   = Join-Path $Root 'vue'

New-Item -ItemType Directory -Force -Path $Tmp, $Logs | Out-Null
$env:TMP = $Tmp
$env:TEMP = $Tmp
$env:OPENBLAS_NUM_THREADS = '1'

# ---------------------------------------------------------------------------
# 工具函数
# ---------------------------------------------------------------------------
function Test-Tcp {
    param([string]$Target, [int]$Port, [int]$TimeoutMs = 1000)
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $task = $client.ConnectAsync($Target, $Port)
        if ($task.Wait($TimeoutMs) -and $client.Connected) { return $true }
        return $false
    } catch { return $false } finally { $client.Dispose() }
}

function Test-Service {
    param([int]$Port)
    return (Test-Tcp '127.0.0.1' $Port) -or (Test-Tcp '::1' $Port)
}

function Stop-OnPort {
    param([int]$Port)
    $pids = Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty OwningProcess -Unique
    foreach ($procId in $pids) {
        if ($procId -and $procId -ne 0) {
            try { Stop-Process -Id $procId -Force -ErrorAction Stop; Write-Host "    已停止占用 $Port 的进程 PID=$procId" }
            catch { Write-Host "    停止 PID=$procId 失败：$($_.Exception.Message)" }
        }
    }
}

function Wait-Service {
    param([int]$Port, [int]$Seconds = 60, [string]$Name = '')
    for ($i = 0; $i -lt $Seconds; $i++) {
        if (Test-Service $Port) { return $true }
        Start-Sleep -Seconds 1
    }
    return $false
}

function Write-Step($text) { Write-Host "`n$text" -ForegroundColor Cyan }

# ---------------------------------------------------------------------------
# 0. 前置检查
# ---------------------------------------------------------------------------
Write-Step '== 环境检查 =='
$missing = @()
if (-not (Test-Path $JavaExe))  { $missing += "JDK: $JavaExe" }
if (-not (Test-Path $Jar))      { $missing += "后端 jar: $Jar（先执行 mvn clean package -DskipTests）" }
if (-not (Test-Path $VenvPy))   { $missing += "Python venv: $VenvPy" }
if (-not (Test-Path (Join-Path $VueDir 'node_modules'))) { $missing += "前端 node_modules" }
if ($missing.Count -gt 0) {
    Write-Host '缺少依赖，先补齐：' -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}
Write-Host '  工具链齐备' -ForegroundColor Green

# ---------------------------------------------------------------------------
# 1. MySQL
# ---------------------------------------------------------------------------
Write-Step '== 1/4 MySQL (3306) =='
if ($Restart -and (Test-Service 3306)) { Stop-OnPort 3306; Start-Sleep -Seconds 2 }

if (Test-Service 3306) {
    Write-Host '  已在运行，跳过' -ForegroundColor Yellow
} else {
    Start-Process -FilePath $MySqlExe -WindowStyle Hidden -PassThru `
        -ArgumentList "--basedir=`"$Mysql`"", "--datadir=`"$MysqlData`"", "--tmpdir=`"$Tmp`"", '--port=3306', '--bind-address=127.0.0.1' `
        -RedirectStandardOutput (Join-Path $Logs 'mysql.out.log') `
        -RedirectStandardError  (Join-Path $Logs 'mysql.err.log') | Out-Null
    if (Wait-Service 3306 40) { Write-Host '  已启动' -ForegroundColor Green }
    else { Write-Host '  启动失败，见 logs\mysql.err.log' -ForegroundColor Red; exit 1 }
}

# ---------------------------------------------------------------------------
# 2. 推荐服务
# ---------------------------------------------------------------------------
Write-Step '== 2/4 推荐服务 FastAPI (8000) =='
if ($Restart -and (Test-Service 8000)) { Stop-OnPort 8000; Start-Sleep -Seconds 2 }

if (Test-Service 8000) {
    Write-Host '  已在运行，跳过' -ForegroundColor Yellow
} else {
    Start-Process -FilePath $VenvPy -WorkingDirectory $PyDir -WindowStyle Hidden -PassThru `
        -ArgumentList '-m', 'uvicorn', 'api_implicit:app', '--host', '127.0.0.1', '--port', '8000' `
        -RedirectStandardOutput (Join-Path $Logs 'uvicorn.out.log') `
        -RedirectStandardError  (Join-Path $Logs 'uvicorn.err.log') | Out-Null
    if (Wait-Service 8000 40) {
        try {
            $h = Invoke-RestMethod 'http://127.0.0.1:8000/health' -TimeoutSec 5
            Write-Host "  已启动（算法=$($h.algo), 用户=$($h.meta.n_users), 商品=$($h.meta.n_items)）" -ForegroundColor Green
        } catch { Write-Host '  已启动（健康检查失败）' -ForegroundColor Yellow }
    } else { Write-Host '  启动失败，见 logs\uvicorn.err.log' -ForegroundColor Red; exit 1 }
}

# ---------------------------------------------------------------------------
# 3. 后端
# ---------------------------------------------------------------------------
Write-Step '== 3/4 后端 Spring Boot (9090) =='
if ($Restart -and (Test-Service 9090)) { Stop-OnPort 9090; Start-Sleep -Seconds 2 }

if (Test-Service 9090) {
    Write-Host '  已在运行，跳过' -ForegroundColor Yellow
} else {
    # 工作目录必须是项目根目录：FileController 用 user.dir + /files/
    Start-Process -FilePath $JavaExe -WorkingDirectory $Root -WindowStyle Hidden -PassThru `
        -ArgumentList '-Dfile.encoding=UTF-8', '-jar', $Jar, '--spring.main.lazy-initialization=true' `
        -RedirectStandardOutput (Join-Path $Logs 'backend.out.log') `
        -RedirectStandardError  (Join-Path $Logs 'backend.err.log') | Out-Null
    if (Wait-Service 9090 90) {
        try {
            $c = Invoke-RestMethod 'http://127.0.0.1:9090/count' -TimeoutSec 10
            Write-Host "  已启动（销售额=$($c.data.total), 商品=$($c.data.goods), 用户=$($c.data.user)）" -ForegroundColor Green
        } catch { Write-Host '  端口已监听，但接口未响应' -ForegroundColor Yellow }
    } else { Write-Host '  启动失败，见 logs\backend.out.log' -ForegroundColor Red; exit 1 }
}

# ---------------------------------------------------------------------------
# 4. 前端
# ---------------------------------------------------------------------------
Write-Step '== 4/4 前端 Vite (5173) =='
if ($Restart -and (Test-Service 5173)) { Stop-OnPort 5173; Start-Sleep -Seconds 2 }

if (Test-Service 5173) {
    Write-Host '  已在运行，跳过' -ForegroundColor Yellow
} else {
    # --host 让 Vite 同时监听 IPv4/IPv6，localhost 和 127.0.0.1 都能打开
    Start-Process -FilePath 'npm.cmd' -WorkingDirectory $VueDir -WindowStyle Hidden -PassThru `
        -ArgumentList 'run', 'dev', '--', '--host' `
        -RedirectStandardOutput (Join-Path $Logs 'vite.out.log') `
        -RedirectStandardError  (Join-Path $Logs 'vite.err.log') | Out-Null
    if (Wait-Service 5173 60) { Write-Host '  已启动' -ForegroundColor Green }
    else { Write-Host '  启动失败，见 logs\vite.err.log' -ForegroundColor Red; exit 1 }
}

# ---------------------------------------------------------------------------
# 汇总
# ---------------------------------------------------------------------------
Write-Step '== 启动完成 =='
$frontCode = (& curl.exe -sS -m 5 -o NUL -w '%{http_code}' 'http://localhost:5173/' 2>$null)
Write-Host ''
Write-Host '  ┌────────────────────────────────────────────────────────┐'
Write-Host '  │  前端商城   http://localhost:5173                      │'
Write-Host '  │  后端接口   http://localhost:9090                      │'
Write-Host '  │  推荐服务   http://localhost:8000/health               │'
Write-Host '  │  数据库     localhost:3306  (库 code2026)              │'
Write-Host '  └────────────────────────────────────────────────────────┘'
Write-Host ''
Write-Host "  前端 HTTP 状态: $frontCode" -ForegroundColor Green
Write-Host '  测试账号: 管理员 admin/admin    用户 aaa/123' -ForegroundColor Gray
Write-Host "  日志目录: $Logs" -ForegroundColor Gray
