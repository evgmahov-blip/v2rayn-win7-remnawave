@echo off
setlocal
chcp 65001 >nul
echo #################### НАЧАЛО ВЫВОДА: V2RAYN WIN7 REPAIR ####################
set "ROOT=%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%scripts\repair.ps1"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" echo [ОШИБКА] Восстановление прервано, код: %RC%
echo #################### КОНЕЦ ВЫВОДА: V2RAYN WIN7 REPAIR ####################
endlocal & exit /b %RC%
