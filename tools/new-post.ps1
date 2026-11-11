<#
.SYNOPSIS
  新建一篇文章（本机没装 Node、用不了 hexo new 时用这个）。

.DESCRIPTION
  在 source\_posts 下生成 YYYY-MM-DD-slug.md，带好 front matter，
  然后用 Typora 打开写正文。写完提交推送即可（见 README）。

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\new-post.ps1 -Title "先学会走" -Category 随笔 -Tags 日记,随笔 -Open

.EXAMPLE
  # 指定英文 slug，网址更干净
  powershell -ExecutionPolicy Bypass -File tools\new-post.ps1 -Title "PHP 数组笔记" -Slug php-array -Category 学习
#>
param(
  [Parameter(Mandatory = $true)][string]$Title,
  [string]$Slug,
  [string]$Category = '',
  [string[]]$Tags = @(),
  [switch]$Open
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$postsDir = Join-Path $root 'source\_posts'
if (-not (Test-Path -LiteralPath $postsDir)) { throw "找不到 $postsDir" }

$now = Get-Date
if ([string]::IsNullOrWhiteSpace($Slug)) {
  $Slug = ($Title -replace '\s+', '-' -replace '[\\/:*?"<>|]', '')
}
$fileName = '{0}-{1}.md' -f $now.ToString('yyyy-MM-dd'), $Slug
$file = Join-Path $postsDir $fileName
if (Test-Path -LiteralPath $file) { throw "已经存在同名文章：$fileName" }

$tagsYaml = ''
if ($Tags.Count -gt 0) { $tagsYaml = '[' + ($Tags -join ', ') + ']' }

$content = @"
---
title: $Title
date: $($now.ToString('yyyy-MM-dd HH:mm:ss'))
categories: $Category
tags: $tagsYaml
description:
---

在这里写正文（Typora 直接写 Markdown 即可）。

## 小标题

正文……

<!-- more -->

## 正文从这里继续

<!--
  小提示：
  1. description 写一句摘要，首页卡片和搜索结果里显示的就是它；不填会截取正文前 200 字
  2. <!-- more --> 之前的段落算摘要，之后的内容要点“阅读全文”才看得到，可以删掉
  3. 图片放在 source\img\ 下，正文里写 ![说明](/img/图片名.png)
-->
"@

Set-Content -LiteralPath $file -Value $content -Encoding UTF8
Write-Host "已创建：$file"
Write-Host ""
Write-Host "写完记得：GitHub Desktop → 提交 → Push origin（推到 src 分支，云端会自动构建发布）"
if ($Open) { Start-Process $file }
