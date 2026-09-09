param([string]$SubscriptionUrl='')
Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
. (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'common.ps1')
Assert-Win7x64
Enable-Tls12
$installDir = Join-Path $env:LOCALAPPDATA 'v2rayN-Win7-Remnawave'
$tmp = Join-Path $env:TEMP ('v2rayn-win7-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
try {
  Write-Host '[1/7] Проверка каталога установки'
  New-Item -ItemType Directory -Force -Path $installDir | Out-Null

  Write-Host '[2/7] Скачивание v2rayN 7.16.9 SelfContained x64'
  $vUrl='https://github.com/2dust/v2rayN/releases/download/7.16.9/v2rayN-windows-64-SelfContained.zip'
  $vSha='5b11b221b1514924a38c684a80a3b2bd00933303b45f71aa2ef73263b3e46827'
  $vZip=Join-Path $tmp 'v2rayN.zip'
  Download-File $vUrl $vZip
  $actual=Get-Sha256 $vZip
  if ($actual -ne $vSha) { throw ('SHA256 v2rayN не совпал. expected='+$vSha+' actual='+$actual) }
  Write-Host '[OK] SHA256 v2rayN проверен.'

  Write-Host '[3/7] Распаковка v2rayN'
  $unpack=Join-Path $tmp 'v2rayN'
  Expand-ZipCompat $vZip $unpack
  $payload=$unpack
  $children=Get-ChildItem $unpack
  if ($children.Count -eq 1 -and $children[0].PSIsContainer) { $payload=$children[0].FullName }
  Get-ChildItem $payload | ForEach-Object { Copy-Item $_.FullName (Join-Path $installDir $_.Name) -Recurse -Force }

  Write-Host '[4/7] Установка Win7 Xray core'
  Install-XrayWin7 $installDir

  Write-Host '[5/7] Сохранение параметров Remnawave'
  if ($SubscriptionUrl) {
    Set-Content -Path (Join-Path $installDir 'REMNAWAVE-SUBSCRIPTION.txt') -Value $SubscriptionUrl -Encoding UTF8
    Write-Host '[OK] URL подписки сохранён локально.'
  } else { Write-Host '[INFO] URL подписки не задан. Его можно добавить в v2rayN вручную.' }

  Write-Host '[6/7] Создание ярлыка'
  $exe=Get-ChildItem $installDir -Filter 'v2rayN.exe' -Recurse | Select-Object -First 1
  if ($exe -eq $null) { throw 'v2rayN.exe не найден после распаковки.' }
  $desktop=[Environment]::GetFolderPath('Desktop')
  $lnk=Join-Path $desktop 'v2rayN Win7 Remnawave.lnk'
  $ws=New-Object -ComObject WScript.Shell
  $sc=$ws.CreateShortcut($lnk)
  $sc.TargetPath=$exe.FullName
  $sc.WorkingDirectory=$exe.DirectoryName
  $sc.Save()

  Write-Host '[7/7] Финальная проверка'
  $xray=Join-Path $installDir 'bin\xray\xray.exe'
  & $xray version | Select-Object -First 1 | ForEach-Object { Write-Host ('[OK] '+$_) }
  Write-Host ('[OK] Установлено: '+$installDir)
  Write-Host '[ВАЖНО] Не обновляй Xray через обычный core updater v2rayN. Используй UPDATE-XRAY.cmd из этого проекта.'
} finally {
  if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
}
