#Requires -Version 5.1
<#
.SYNOPSIS
    重置管理员 / 普通用户的密码（忘记密码时用）

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File run\reset-admin-password.ps1
    powershell -ExecutionPolicy Bypass -File run\reset-admin-password.ps1 -Username aaa -Password 123 -Table user
#>
param(
    [string]$Username = 'admin',
    [string]$Password = 'admin',
    [ValidateSet('admin', 'user')]
    [string]$Table = 'admin'
)

$ErrorActionPreference = 'Stop'

$mysql = 'D:\dsh-tools\mysql\mysql-8.0.28-winx64\bin\mysql.exe'
if (-not (Test-Path $mysql)) {
    Write-Host "找不到 mysql 客户端：$mysql" -ForegroundColor Red
    exit 1
}

# 简单转义，避免密码里的单引号把 SQL 弄断
$safeUser = $Username.Replace("'", "''")
$safePwd = $Password.Replace("'", "''")
$roleValue = if ($Table -eq 'admin') { '管理员' } else { '普通用户' }

$sql = @"
UPDATE ``$Table`` SET ``password`` = '$safePwd', ``role`` = '$roleValue' WHERE ``username`` = '$safeUser';
SELECT id, username, ``password`` AS pwd, role FROM ``$Table`` WHERE ``username`` = '$safeUser';
"@

Write-Host "正在重置 $Table 表中 '$Username' 的密码为 '$Password' ..." -ForegroundColor Cyan

# 用临时配置文件传账号密码，避免 mysql 输出
# "Using a password on the command line interface can be insecure" 警告
$optFile = Join-Path $env:TEMP ('dsh-mysql-' + [guid]::NewGuid().ToString('N') + '.cnf')
"[client]`nuser=root`npassword=$($env:DB_PASSWORD)`ndefault-character-set=utf8mb4`n" |
    Set-Content -Path $optFile -Encoding ASCII
try {
    & $mysql "--defaults-extra-file=$optFile" code2026 -e $sql
} finally {
    Remove-Item $optFile -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host '完成。可以用下面的账号登录：' -ForegroundColor Green
Write-Host "  账号: $Username" -ForegroundColor Green
Write-Host "  密码: $Password" -ForegroundColor Green
Write-Host "  角色: $roleValue" -ForegroundColor Green
