Set-StrictMode -Version 2
$ErrorActionPreference='Continue'
$installDir = Join-Path $env:LOCALAPPDATA 'v2rayN-Win7-Remnawave'
$os=Get-WmiObject Win32_OperatingSystem
Write-Host ('OS: '+$os.Caption+' '+$os.Version+' '+$os.OSArchitecture)
Write-Host ('InstallDir: '+$installDir)
$gui=Get-ChildItem $installDir -Filter 'v2rayN.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if ($gui) { Write-Host ('v2rayN: '+$gui.FullName) } else { Write-Host 'v2rayN: NOT FOUND' }
$xray=Join-Path $installDir 'bin\xray\xray.exe'
if (Test-Path $xray) {
  Write-Host ('Xray: '+$xray)
  & $xray version | Select-Object -First 3
} else { Write-Host 'Xray: NOT FOUND' }
$marker=Join-Path $installDir 'WIN7-XRAY-CORE.txt'
if (Test-Path $marker) { Write-Host 'Core marker:'; Get-Content $marker }
$sub=Join-Path $installDir 'REMNAWAVE-SUBSCRIPTION.txt'
if (Test-Path $sub) { Write-Host 'Remnawave subscription: configured locally' } else { Write-Host 'Remnawave subscription: not saved by installer' }
Write-Host ('PowerShell: '+$PSVersionTable.PSVersion.ToString())
