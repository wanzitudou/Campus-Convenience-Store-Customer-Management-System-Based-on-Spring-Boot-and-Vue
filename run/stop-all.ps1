#Requires -Version 5.1
<#
.SYNOPSIS
    停止校园小卖部客户管理系统的各个服务

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File run\stop-all.ps1
    powershell -ExecutionPolicy Bypass -File run\stop-all.ps1 -IncludeDb
#>
param(
    [switch]$IncludeDb
)

$ErrorActionPreference = 'Continue'

function Stop-OnPort {
    param([int]$Port, [string]$Name)
    $pids = Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty OwningProcess -Unique
    if (-not $pids) { Write-Host "  $Name ($Port) 未在运行" -ForegroundColor DarkGray; return }
    foreach ($procId in $pids) {
        if ($procId -and $procId -ne 0) {
            try {
                Stop-Process -Id $procId -Force -ErrorAction Stop
                Write-Host "  $Name ($Port) 已停止，PID=$procId" -ForegroundColor Green
            } catch {
                Write-Host "  $Name ($Port) 停止失败：$($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

Write-Host '停止前端 / 后端 / 推荐服务 ...' -ForegroundColor Cyan
Stop-OnPort 5173 '前端 Vite'
Stop-OnPort 9090 '后端 Spring Boot'
Stop-OnPort 8000 '推荐服务 FastAPI'

if ($IncludeDb) {
    Write-Host '停止 MySQL ...' -ForegroundColor Cyan
    Stop-OnPort 3306 'MySQL'
}

Write-Host '完成' -ForegroundColor Cyan
