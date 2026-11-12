<#
.SYNOPSIS
  在 Typora 里打开指定文件（找不到 Typora 才退回系统默认程序）。

.DESCRIPTION
  这台机器 .md 的默认打开方式是 WorkBuddy.md，不是 Typora，
  所以脚本里不能直接 Start-Process 文件，要显式指定 Typora 的 exe。
  想换编辑器就改下面的 $candidates 列表。
#>
function Resolve-EditorPath {
  $candidates = @(
    'D:\tools\Typora\Typora.exe',
    (Join-Path $env:LOCALAPPDATA 'Programs\Typora\Typora.exe'),
    'C:\Program Files\Typora\Typora.exe',
    'C:\Program Files (x86)\Typora\Typora.exe',
    (Join-Path $env:ProgramFiles 'Typora\Typora.exe')
  )
  foreach ($exe in $candidates) {
    if ($exe -and (Test-Path -LiteralPath $exe)) { return $exe }
  }
  return $null
}

function Open-InEditor {
  param([Parameter(Mandatory = $true)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { throw "文件不存在：$Path" }
  $exe = Resolve-EditorPath
  if ($exe) {
    Start-Process -FilePath $exe -ArgumentList "`"$Path`""
  } else {
    # 没装 Typora 就交给系统默认程序
    Start-Process -FilePath $Path
  }
}
