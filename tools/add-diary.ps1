<#
.SYNOPSIS
  新建一篇日记（一天一个文件，页面会自动按日期倒序 + 分页）。

.DESCRIPTION
  在 source\_diary\ 下生成 YYYY-MM-DD.md 并用 Typora 打开。
  - 文件名（或 front matter 里的 date）决定排序，**不需要手动调顺序**
  - 想给这天起个别的标题，就在 front matter 里写 title:

  用法：
    1) 双击项目根目录的「写日记.bat」→ 回车用今天（或输入 2026-11-12）
    2) 命令行：tools\add-diary.ps1 -Date 2026-11-12 -Text "今天做了啥"
#>
param(
  [string]$Date,
  [string]$Text,
  [string]$Title,
  [string]$Dir,
  [switch]$Open
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Dir)) { $Dir = Join-Path $root 'source\_diary' }
if (-not (Test-Path -LiteralPath $Dir)) { New-Item -ItemType Directory -Path $Dir -Force | Out-Null }

function Ask([string]$prompt, [string]$default = '') {
  try {
    $v = Read-Host $prompt
    if ([string]::IsNullOrWhiteSpace($v)) { return $default }
    return $v.Trim()
  } catch {
    return $default
  }
}

if ([string]::IsNullOrWhiteSpace($Date)) {
  $Date = Ask ("日期（YYYY-MM-DD，回车=今天 {0}）" -f (Get-Date -Format 'yyyy-MM-dd')) (Get-Date -Format 'yyyy-MM-dd')
}
if ($Date -notmatch '^\d{4}-\d{2}-\d{2}$') { throw "日期格式不对：$Date（要 2026-11-12 这种）" }

$file = Join-Path $Dir "$Date.md"
if (Test-Path -LiteralPath $file) {
  Write-Host "这天已经有日记了，直接打开给你改：$file" -ForegroundColor Yellow
  if ($Open) { Start-Process $file }
  return
}

$fm = "---`ndate: $Date`n"
if (-not [string]::IsNullOrWhiteSpace($Title)) { $fm += "title: $Title`n" }
$fm += "---`n`n"

$body = if ([string]::IsNullOrWhiteSpace($Text)) { "" } else { "$Text`n" }

[System.IO.File]::WriteAllText($file, $fm + $body, (New-Object System.Text.UTF8Encoding($false)))

Write-Host ""
Write-Host "已创建：$file" -ForegroundColor Green
Write-Host "页面上会自动排到最前面（按日期倒序），不用管顺序。" -ForegroundColor DarkGray
Write-Host ""
Write-Host "写完正文后：" -ForegroundColor Yellow
Write-Host "  GitHub Desktop -> 选 hexo-blog -> 填说明 -> Commit to src -> Push origin"

if ($Open) { Start-Process $file }
