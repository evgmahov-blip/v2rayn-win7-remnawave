@echo off
setlocal
chcp 65001 >nul
echo #################### НАЧАЛО ВЫВОДА: V2RAYN WIN7 DIAG ####################
set "ROOT=%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%scripts\diag.ps1"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" echo [ОШИБКА] Диагностика завершилась с кодом: %RC%
echo #################### КОНЕЦ ВЫВОДА: V2RAYN WIN7 DIAG ####################
endlocal & exit /b %RC%
