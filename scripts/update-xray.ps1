Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
. (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'common.ps1')
Assert-Win7x64
$installDir = Join-Path $env:LOCALAPPDATA 'v2rayN-Win7-Remnawave'
if (-not (Test-Path $installDir)) { throw 'Установка не найдена. Сначала запусти INSTALL.cmd.' }
$proc=Get-Process -Name 'v2rayN','xray' -ErrorAction SilentlyContinue
if ($proc) { throw 'Перед обновлением закрой v2rayN/Xray. Автоматически процессы не завершаю.' }
$backup=Join-Path $installDir ('backup-xray-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$xrayDir=Join-Path $installDir 'bin\xray'
if (Test-Path $xrayDir) { Copy-Item $xrayDir $backup -Recurse -Force; Write-Host ('[OK] Резервная копия: '+$backup) }
try {
  Install-XrayWin7 $installDir
  Write-Host '[OK] Win7 Xray core обновлён.'
} catch {
  if (Test-Path $backup) {
    if (Test-Path $xrayDir) { Remove-Item $xrayDir -Recurse -Force -ErrorAction SilentlyContinue }
    Copy-Item $backup $xrayDir -Recurse -Force
    Write-Host '[ROLLBACK] Предыдущее ядро восстановлено.'
  }
  throw
}
