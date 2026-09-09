@echo off
setlocal
chcp 65001 >nul
echo #################### НАЧАЛО ВЫВОДА: V2RAYN WIN7 REMNAWAVE INSTALL ####################
set "ROOT=%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%scripts\install.ps1" %*
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" echo [ОШИБКА] Установка прервана, код: %RC%
echo #################### КОНЕЦ ВЫВОДА: V2RAYN WIN7 REMNAWAVE INSTALL ####################
endlocal & exit /b %RC%
