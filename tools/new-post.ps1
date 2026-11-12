<#
.SYNOPSIS
  新建一篇文章（本机没装 Node、用不了 hexo new 时用这个）。

.DESCRIPTION
  在 source\_posts 下生成 YYYY-MM-DD-slug.md，带好 front matter。

  两种用法：
    1) 双击项目根目录的「新建文章.bat」，按提示输入标题 / 分类 / 标签
    2) 命令行带参数，例如：
       powershell -ExecutionPolicy Bypass -File tools\new-post.ps1 -Title "标题" -Category 随笔 -Tags 日记,随笔 -Open
#>
param(
  [string]$Title,
  [string]$Slug,
  [string]$Category,
  [string[]]$Tags,
  [switch]$Open
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '_open-editor.ps1')
$root = Split-Path -Parent $PSScriptRoot
$postsDir = Join-Path $root 'source\_posts'
if (-not (Test-Path -LiteralPath $postsDir)) { throw "找不到 $postsDir" }

function Ask([string]$prompt, [string]$default = '') {
  try {
    $v = Read-Host $prompt
    if ([string]::IsNullOrWhiteSpace($v)) { return $default }
    return $v.Trim()
  } catch {
    # 非交互环境（比如被脚本调用）就退回默认值
    return $default
  }
}

# ---------- 补全信息 ----------
if ([string]::IsNullOrWhiteSpace($Title)) { $Title = Ask "文章标题（必填）" }
if ([string]::IsNullOrWhiteSpace($Title)) { throw "标题为空，已取消" }

if ([string]::IsNullOrWhiteSpace($Category)) { $Category = Ask "分类（回车默认：随笔）" '随笔' }

if (-not $Tags -or $Tags.Count -eq 0) {
  $t = Ask "标签（逗号分隔，可留空）"
  if (-not [string]::IsNullOrWhiteSpace($t)) {
    $Tags = $t -split '[,，]' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
  }
}

# ---------- 生成文件 ----------
$now = Get-Date
if ([string]::IsNullOrWhiteSpace($Slug)) {
  $Slug = ($Title -replace '\s+', '-' -replace '[\\/:*?"<>|]', '')
}
$fileName = '{0}-{1}.md' -f $now.ToString('yyyy-MM-dd'), $Slug
$file = Join-Path $postsDir $fileName
if (Test-Path -LiteralPath $file) { throw "已经存在同名文章：$fileName" }

$tagsYaml = ''
if ($Tags -and $Tags.Count -gt 0) { $tagsYaml = '[' + ($Tags -join ', ') + ']' }

$content = @"
---
title: $Title
date: $($now.ToString('yyyy-MM-dd HH:mm:ss'))
categories: $Category
tags: $tagsYaml
description:
---

在这里写正文。

<!-- more -->
"@

# 必须是「UTF-8 无 BOM」：Windows PowerShell 5.1 的 Set-Content -Encoding UTF8 会加 BOM，
# 而 BOM 会让 Hexo 的 front matter 解析失败（文章会变成没有标题/日期的散文件）
[System.IO.File]::WriteAllText($file, $content, (New-Object System.Text.UTF8Encoding($false)))

Write-Host ""
Write-Host "已创建：$file" -ForegroundColor Green
Write-Host ("网址会是你：/{0}/{1}/" -f $now.ToString('yyyy/MM/dd'), $Slug) -ForegroundColor DarkGray
Write-Host ""
Write-Host "写完正文后：" -ForegroundColor Yellow
Write-Host "  GitHub Desktop -> 选 hexo-blog 仓库 -> 填一句说明 -> Commit to src -> Push origin"
Write-Host "  1~2 分钟后线上自动更新"
Write-Host ""

if ($Open) { Open-InEditor -Path $file }
