<#
.SYNOPSIS
  把文章里引用的「本地绝对路径图片」搬进站点，并改写成站内路径。

.DESCRIPTION
  起因：Typora 插入图片时默认记的是本机路径（比如
  C:\Users\lenovo\AppData\Roaming\Typora\typora-user-images\image-xxx.png），
  这种路径在网站上必然打不开。

  这个脚本会：
    1. 扫描 source\_posts\*.md
    2. 找出 <img src="C:\..."> 和 ![](C:\...) 这类引用
    3. 把图片复制到 source\img\posts\<文章slug>\ 下（重命名成 ASCII 名字）
    4. 把正文里的路径改成 /img/posts/<slug>/xxx.png
    5. 找不到的图片会列出来提醒（不会破坏原文）

  用法：双击「整理图片.bat」，或
        powershell -ExecutionPolicy Bypass -File tools\fix-post-images.ps1
#>
param(
  [string]$PostsDir,
  [switch]$WhatIfOnly
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($PostsDir)) { $PostsDir = Join-Path $root 'source\_posts' }
$imageRoot = Join-Path $root 'source\img\posts'
if (-not (Test-Path -LiteralPath $PostsDir)) { throw "找不到文章目录：$PostsDir" }

$missing = @()
$moved = 0
$changedFiles = 0

# <img src="C:\..."> 或 <img src='C:\...'>
$htmlRe = [regex]'(<img[^>]*?\ssrc\s*=\s*["''])([A-Za-z]:\\[^"'']+)(["''])'
# ![](C:\...) 或 ![alt](C:\...)
$mdRe = [regex]'(!\[[^\]]*\]\()([A-Za-z]:\\[^)\r\n]+)(\))'

function Get-TargetPath([string]$slug, [string]$srcPath, [hashtable]$map) {
  if ($map.ContainsKey($srcPath)) { return $map[$srcPath] }
  if (-not (Test-Path -LiteralPath $srcPath)) { return $null }
  $dir = Join-Path $imageRoot $slug
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $ext = [System.IO.Path]::GetExtension($srcPath)
  if ([string]::IsNullOrWhiteSpace($ext)) { $ext = '.png' }
  $n = (Get-ChildItem -LiteralPath $dir -File -ErrorAction SilentlyContinue).Count + 1
  do {
    $name = ('img-{0:d2}{1}' -f $n, $ext.ToLower())
    $dest = Join-Path $dir $name
    $n++
  } while (Test-Path -LiteralPath $dest)
  Copy-Item -LiteralPath $srcPath -Destination $dest -Force
  $url = "/img/posts/$slug/$name"
  $map[$srcPath] = $url
  $script:moved++
  return $url
}

foreach ($file in Get-ChildItem -LiteralPath $PostsDir -Filter '*.md' -File) {
  $slug = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
  $text = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
  $before = $text
  $map = @{}

  $replacer = {
    param($m)
    $url = Get-TargetPath -slug $slug -srcPath $m.Groups[2].Value -map $map
    if ($null -eq $url) {
      $script:missing += "$($file.Name) -> $($m.Groups[2].Value)"
      return $m.Value
    }
    return $m.Groups[1].Value + $url + $m.Groups[3].Value
  }

  $text = $htmlRe.Replace($text, [System.Text.RegularExpressions.MatchEvaluator]$replacer)
  $text = $mdRe.Replace($text, [System.Text.RegularExpressions.MatchEvaluator]$replacer)

  if ($text -ne $before) {
    if (-not $WhatIfOnly) {
      [System.IO.File]::WriteAllText($file.FullName, $text, (New-Object System.Text.UTF8Encoding($false)))
    }
    $changedFiles++
    Write-Host ("已处理：" + $file.Name) -ForegroundColor Green
  }
}

Write-Host ""
Write-Host ("共搬移 {0} 张图片，修改 {1} 篇文章" -f $moved, $changedFiles) -ForegroundColor Cyan
if ($missing.Count -gt 0) {
  Write-Host ""
  Write-Host "以下图片在磁盘上找不到，需要你手动补：" -ForegroundColor Yellow
  $missing | ForEach-Object { Write-Host "  $_" }
}
if ($changedFiles -gt 0) {
  Write-Host ""
  Write-Host "下一步：GitHub Desktop -> Commit to src -> Push origin" -ForegroundColor Yellow
}
