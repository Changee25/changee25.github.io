<#
.SYNOPSIS
  往日记页顶部插入一条新日记（最新的在最上面）。

.DESCRIPTION
  日记就是 source\diary\index.md 这一个文件，每条用 `#### 日期` 起头。
  这个脚本把新的日期小节插到最上面，然后可以用 Typora 打开接着写。

  用法：
    1) 双击项目根目录的「写日记.bat」→ 回车用今天日期（或输入 2026-11-12 这种）
    2) 命令行：tools\add-diary.ps1 -Date 2026-11-12 -Text "今天做了啥"
#>
param(
  [string]$Date,
  [string]$Text,
  [string]$File,
  [switch]$Open
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($File)) { $File = Join-Path $root 'source\diary\index.md' }
if (-not (Test-Path -LiteralPath $File)) { throw "找不到日记文件：$File" }

$MARK = '<!-- 最新的写在最上面'

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

$raw = [System.IO.File]::ReadAllText($File, [System.Text.Encoding]::UTF8).Replace("`r`n", "`n")
$heading = "#### $Date"

if ($raw -match [regex]::Escape($heading)) {
  Write-Host "日记里已经有 $Date 这条了，不重复插入。" -ForegroundColor Yellow
  if ($Open) { Start-Process $File }
  return
}

$entry = if ([string]::IsNullOrWhiteSpace($Text)) {
  "$heading`n`n"
} else {
  "$heading`n`n$Text`n`n"
}

$idx = $raw.IndexOf($MARK)
if ($idx -ge 0) {
  # 插到标记注释那一行的末尾
  $lineEnd = $raw.IndexOf("`n", $idx)
  if ($lineEnd -lt 0) { $lineEnd = $raw.Length }
  $before = $raw.Substring(0, $lineEnd + 1)
  $after = $raw.Substring($lineEnd + 1).TrimStart("`n")
  $out = $before + "`n" + $entry + $after
} else {
  # 没有标记就插在 front matter 之后
  $m = [regex]::Match($raw, '^---\n.*?\n---\n', [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if (-not $m.Success) { throw "日记文件缺少 front matter，已停止" }
  $before = $m.Value
  $after = $raw.Substring($m.Length).TrimStart("`n")
  $out = $before + "`n" + $entry + $after
}

[System.IO.File]::WriteAllText($File, $out, (New-Object System.Text.UTF8Encoding($false)))

Write-Host ""
Write-Host "已在最上面插入：$heading" -ForegroundColor Green
Write-Host "文件：$File"
Write-Host ""
Write-Host "接着在 Typora 里那个日期下面写就行。写完：" -ForegroundColor Yellow
Write-Host "  GitHub Desktop -> 选 hexo-blog -> 填说明 -> Commit to src -> Push origin"

if ($Open) { Start-Process $File }
