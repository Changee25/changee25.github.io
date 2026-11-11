<#
.SYNOPSIS
  一键把任意图片做成博客头像 + 浏览器标签小图标。

.DESCRIPTION
  输入一张图片（jpg / png / bmp / gif），自动：
    1. 居中裁成正方形
    2. 缩放成 512×512 JPEG（质量 90）→ source\img\avatar.jpg        （导航栏 / 关于页头像）
    3. 缩放成 64×64  PNG          → source\img\avatar-favicon.png  （浏览器标签图标）
  原图不动。跑完执行一次 hexo generate 即可生效。

  为什么头像用 jpg：同样 512×512，照片类图片存成 png 要 600 KB 以上，
  jpg 只要几十 KB。透明底图片会被自动填成导航栏同色（#2f4154）而不是白底。

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\update-avatar.ps1 -ImagePath "C:\Users\lenovo\Pictures\me.png"

.EXAMPLE
  # 只生成到别处看看效果，不覆盖站点图片
  powershell -ExecutionPolicy Bypass -File tools\update-avatar.ps1 -ImagePath me.jpg -OutDir D:\tmp\test
#>
param(
  [Parameter(Mandatory = $true)][string]$ImagePath,
  [string]$OutDir,
  [int]$AvatarSize = 512,
  [int]$FaviconSize = 64
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
if (-not ('System.Drawing.Bitmap' -as [type])) {
  Add-Type -AssemblyName System.Drawing.Common -ErrorAction SilentlyContinue
}

$img = (Resolve-Path -LiteralPath $ImagePath -ErrorAction Stop).Path
$ext = [System.IO.Path]::GetExtension($img).ToLower()
if ($ext -notin @('.jpg', '.jpeg', '.png', '.bmp', '.gif')) {
  throw "这个格式先不支持：$ext（请用 jpg / png / bmp / gif；webp 先在画图里另存为 png）"
}

if ([string]::IsNullOrWhiteSpace($OutDir)) {
  $OutDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'source\img'
}
if (-not (Test-Path -LiteralPath $OutDir)) {
  New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

function Save-Square {
  param($source, $rect, $size, $path, $jpegQuality)

  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  try {
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    # 透明底填成导航栏同色，避免白底方块
    $g.Clear([System.Drawing.Color]::FromArgb(47, 65, 84))
    $destRect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
    $g.DrawImage($source, $destRect, $rect, [System.Drawing.GraphicsUnit]::Pixel)
  } finally {
    $g.Dispose()
  }

  $isJpeg = ([System.IO.Path]::GetExtension($path).ToLower() -in @('.jpg', '.jpeg'))
  if ($isJpeg) {
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
      Where-Object { $_.MimeType -eq 'image/jpeg' } | Select-Object -First 1
    $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
      [System.Drawing.Imaging.Encoder]::Quality, [int]$jpegQuality)
    $bmp.Save($path, $codec, $ep)
    $ep.Dispose()
  } else {
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  }
  $bmp.Dispose()
}

$src = [System.Drawing.Image]::FromFile($img)
try {
  Write-Host ("原图：{0} × {1} 像素" -f $src.Width, $src.Height)

  $side = [Math]::Min($src.Width, $src.Height)
  $sx = [int](($src.Width - $side) / 2)
  $sy = [int](($src.Height - $side) / 2)
  $cropRect = New-Object System.Drawing.Rectangle($sx, $sy, $side, $side)

  $avatar = Join-Path $OutDir 'avatar.jpg'
  $favicon = Join-Path $OutDir 'avatar-favicon.png'
  Save-Square -source $src -rect $cropRect -size $AvatarSize -path $avatar -jpegQuality 90
  Save-Square -source $src -rect $cropRect -size $FaviconSize -path $favicon -jpegQuality 90
} finally {
  $src.Dispose()
}

$oldPng = Join-Path $OutDir 'avatar.png'
if (Test-Path -LiteralPath $oldPng) {
  Remove-Item -LiteralPath $oldPng -Force
  Write-Host "已删除旧的 avatar.png（配置已改为读 avatar.jpg）"
}

foreach ($f in @($avatar, $favicon)) {
  $len = (Get-Item -LiteralPath $f).Length
  Write-Host ("已生成：{0}  ({1:N1} KB)" -f $f, ($len / 1KB))
}
Write-Host ""
Write-Host "下一步：在 hexo-blog 目录执行   npx hexo generate   然后 Ctrl+F5 强制刷新浏览器"
