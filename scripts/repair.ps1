Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
. (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'common.ps1')
Assert-Win7x64
$installDir = Join-Path $env:LOCALAPPDATA 'v2rayN-Win7-Remnawave'
if (-not (Test-Path $installDir)) { throw 'Установка не найдена. Сначала запусти INSTALL.cmd.' }
$proc=Get-Process -Name 'v2rayN','xray' -ErrorAction SilentlyContinue
if ($proc) { throw 'Закрой v2rayN/Xray перед восстановлением. Процессы автоматически не завершаю.' }
$tmp = Join-Path $env:TEMP ('v2rayn-repair-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
try {
  $backup=Join-Path $installDir ('repair-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
  New-Item -ItemType Directory -Force -Path $backup | Out-Null
  foreach($name in @('guiConfigs','REMNAWAVE-SUBSCRIPTION.txt','WIN7-XRAY-CORE.txt')) {
    $src=Join-Path $installDir $name
    if (Test-Path $src) { Copy-Item $src (Join-Path $backup $name) -Recurse -Force }
  }
  Write-Host ('[OK] Пользовательские данные сохранены: '+$backup)
  $vUrl='https://github.com/2dust/v2rayN/releases/download/7.16.9/v2rayN-windows-64-SelfContained.zip'
  $vSha='5b11b221b1514924a38c684a80a3b2bd00933303b45f71aa2ef73263b3e46827'
  $zip=Join-Path $tmp 'v2rayN.zip'
  Download-File $vUrl $zip
  if ((Get-Sha256 $zip) -ne $vSha) { throw 'SHA256 v2rayN не совпал.' }
  $unpack=Join-Path $tmp 'unpack'
  Expand-ZipCompat $zip $unpack
  $payload=$unpack
  $children=Get-ChildItem $unpack
  if ($children.Count -eq 1 -and $children[0].PSIsContainer) { $payload=$children[0].FullName }
  Get-ChildItem $payload | ForEach-Object { Copy-Item $_.FullName (Join-Path $installDir $_.Name) -Recurse -Force }
  Install-XrayWin7 $installDir
  foreach($name in @('guiConfigs','REMNAWAVE-SUBSCRIPTION.txt')) {
    $src=Join-Path $backup $name
    if (Test-Path $src) { Copy-Item $src (Join-Path $installDir $name) -Recurse -Force }
  }
  Write-Host '[OK] Восстановление завершено.'
} finally {
  if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
}
