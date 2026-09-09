@echo off
setlocal
chcp 65001 >nul
echo #################### НАЧАЛО ВЫВОДА: V2RAYN WIN7 XRAY UPDATE ####################
set "ROOT=%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%scripts\update-xray.ps1"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" echo [ОШИБКА] Обновление Xray прервано, код: %RC%
echo #################### КОНЕЦ ВЫВОДА: V2RAYN WIN7 XRAY UPDATE ####################
endlocal & exit /b %RC%
