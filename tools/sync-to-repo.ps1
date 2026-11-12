<#
.SYNOPSIS
  把 public/ 的构建产物同步进旧站仓库并提交，之后你去 GitHub Desktop 点一下 Push 就行。

.DESCRIPTION
  站点源码在 D:\DSH\hexo-blog（本目录），真正推送的仓库是 D:\DSH\changee25.github.io。
  这个脚本做三件事：
    1. 可选：先 hexo clean + hexo generate（加 -Build）
    2. 用 robocopy /MIR 把 public/ 镜像进仓库（保护 .git）
    3. git add + commit

  注：这台机器的 PATH 是坏的，所以脚本里用完整路径调 robocopy / git。

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\sync-to-repo.ps1

.EXAMPLE
  # 改完文章后：先重新构建，再同步
  powershell -ExecutionPolicy Bypass -File tools\sync-to-repo.ps1 -Build
#>
param(
  [string]$RepoPath = 'D:\DSH\changee25.github.io',
  [switch]$Build
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

if (-not (Test-Path -LiteralPath $RepoPath)) { throw "找不到仓库目录：$RepoPath" }
if (-not (Test-Path -LiteralPath (Join-Path $root 'public'))) { throw "找不到 public\，先 hexo generate" }

function Resolve-Exe {
  param([string]$Name, [string]$Fallback)
  $cmd = Get-Command $Name -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  if (Test-Path -LiteralPath $Fallback) { return $Fallback }
  throw "找不到 $Name"
}

$robocopy = Join-Path $env:SystemRoot 'System32\robocopy.exe'
if (-not (Test-Path -LiteralPath $robocopy)) { throw "找不到 robocopy：$robocopy" }
$git = Resolve-Exe -Name 'git' -Fallback 'D:\tools\Git\cmd\git.exe'

if ($Build) {
  Write-Host '==> hexo clean + generate'
  Push-Location $root
  try {
    & npx hexo clean
    & npx hexo generate
  } finally {
    Pop-Location
  }
}

Write-Host "==> 同步 public -> $RepoPath"
& $robocopy (Join-Path $root 'public') $RepoPath /MIR /XD .git /NFL /NDL /NJH /NJS /R:1 /W:1 | Out-Null
$code = $LASTEXITCODE
if ($code -ge 8) { throw "robocopy 失败，退出码 $code" }

Copy-Item -LiteralPath (Join-Path $root 'public\.nojekyll') -Destination (Join-Path $RepoPath '.nojekyll') -Force

Write-Host '==> git add + commit'
& $git -C $RepoPath add -A
$msg = 'update site: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm')
& $git -C $RepoPath commit -m $msg
if ($LASTEXITCODE -ne 0) { Write-Host '（没有改动需要提交）' }

Write-Host ''
Write-Host '下一步：'
Write-Host '  · GitHub Desktop 打开该仓库 -> 点 Push origin'
Write-Host "  · 或命令行：$git -C `"$RepoPath`" push origin main"
