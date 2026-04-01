@echo off
setlocal enabledelayedexpansion
title RenderMaX Legacy 7v1.0
mode con cols=90 lines=32

:: --- COMPROBACIÓN DE PRIVILEGIOS ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo  [!] ACCESO DENEGADO
    echo  ------------------------------------------------------------
    echo  Este script requiere privilegios administrativos para 
    echo  modificar registros del sistema y optimizar servicios.
    echo.
    echo  Por favor, cierre y ejecute como ADMINISTRADOR.
    echo  ------------------------------------------------------------
    pause >nul
    exit /b
)

:: --- DETECTAR VERSIÓN DE WINDOWS ---
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j

:MENU
cls
color 0F
echo.
echo  [94m  o-------------------------------------------------------------------------o [0m
echo  [94m  ^|                      [97mRENDERMAX Legacy 7[94m                       ^| [0m
echo  [94m  o-------------------------------------------------------------------------o [0m
echo  [94m  ^|[0m  SISTEMA: Windows %VERSION%   [94m^|[0m  ESTADO: Administrador   [94m^|[0m  USUARIO: %username% [94m^| [0m
echo  [94m  o-------------------------------------------------------------------------o [0m
echo.
echo      [96m[1][0m [1mMantenimiento de Imagen[0m     [90m(SFC Scan, DISM Health, CheckDisk)[0m
echo      [96m[2][0m [1mSaneamiento de Almacenamiento[0m [90m(WinUpdate, Temp, Prefetch, Logs)[0m
echo      [96m[3][0m [1mOptimizacion de Red Pro[0m       [90m(DNS Flush, IP Reset, Winsock)[0m
echo      [96m[4][0m [1mDebloat ^& System Clean[0m        [90m(Apps Basura)[0m
echo      [96m[5][0m [1mPrivacidad ^& Telemetria[0m       [90m(Privacy Flags, DiagTrack, Services)[0m
echo      [96m[6][0m [1mPersonalizacion UI[0m            [90m(Dark Mode, Classic Menu, Aero)[0m
echo.
echo  [94m  o-------------------------------------------------------------------------o [0m
echo  [94m  ^|  [92m[A] EJECUTAR OPTIMIZACION TOTAL[0m    [93m[R] RESTAURAR[0m    [91m[X] SALIR[0m  [94m^| [0m
echo  [94m  o-------------------------------------------------------------------------o [0m
echo.
echo   [97mSeleccione una operacion para continuar...[0m

choice /c 123456ARX /n
set "opt=%errorlevel%"

if %opt%==9 exit
if %opt%==8 goto RESTORE
if %opt%==7 goto TOTAL_OPTIMIZATION
if %opt%==6 goto UI_TWEAKS
if %opt%==5 goto PRIVACY_PRO
if %opt%==4 goto DEBLOAT_SYSTEM
if %opt%==3 goto NETWORK_PRO
if %opt%==2 goto STORAGE_CLEAN
if %opt%==1 goto SYS_MAINTENANCE

:: --- MÓDULOS DE FUNCIÓN ---

:SYS_MAINTENANCE
cls
echo [94m[*] Iniciando Auditoria de Sistema...[0m
echo.
echo [1/3] Ejecutando System File Checker...
sfc /scannow
if "%VERSION:~0,1%"=="1" (
    echo [2/3] Reparando Imagen de Despliegue (DISM)...
    dism /online /cleanup-image /restorehealth
)
echo [3/3] Verificando sectores logicos...
echo N | chkdsk C:
echo.
echo [92m[+] Auditoria completada.[0m
pause
goto MENU

:STORAGE_CLEAN
cls
echo [94m[*] Saneamiento de Almacenamiento...[0m
echo.
echo [-] Purgando carpetas temporales...
del /s /f /q "%temp%\*.*" >nul 2>&1
del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
echo [-] Limpiando cache de Prefetch y Shadow Copy...
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1
if "%VERSION:~0,1%"=="1" (
    echo [-] Comprimiendo base de Windows Update (Component Cleanup)...
    dism /online /cleanup-image /startcomponentcleanup /resetbase
)
echo.
echo [92m[+] Limpieza profunda finalizada.[0m
pause
goto MENU

:NETWORK_PRO
cls
echo [94m[*] Reconfigurando Stack TCP/IP...[0m
ipconfig /flushdns >nul
netsh winsock reset >nul
netsh int ip reset >nul
echo [92m[+] Red optimizada. La conexion se ha refrescado.[0m
pause
goto MENU

:DEBLOAT_SYSTEM
cls
echo [94m[*] Eliminando Componentes Innecesarios...[0m
taskkill /f /im OneDrive.exe >nul 2>&1
echo [-] Desinstalando Microsoft OneDrive...
if exist "%SystemRoot%\System32\OneDriveSetup.exe" "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall
if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall
if "%VERSION:~0,1%"=="1" (
    echo [-] Removiendo aplicaciones basura de fabrica...
    powershell -command "Get-AppxPackage *CandyCrush* | Remove-AppxPackage"
    powershell -command "Get-AppxPackage *Spotify* | Remove-AppxPackage"
)
echo.
echo [92m[+] Sistema aligerado.[0m
pause
goto MENU

:PRIVACY_PRO
cls
echo [94m[*] Blindaje de Privacidad...[0m
:: Desactivar Telemetría
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul
:: Detener servicios de rastreo
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start=disabled >nul 2>&1
echo [92m[+] Telemetria y recoleccion de datos desactivada.[0m
pause
goto MENU

:UI_TWEAKS
cls
echo [94m[*] Personalizacion de Interfaz...[0m
if "%VERSION:~0,1%"=="1" (
    echo [1] Aplicando Modo Oscuro...
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 0 /f >nul
    echo [2] Restaurando Menu Contextual Clasico (Win11)...
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve >nul 2>&1
) else (
    echo [!] Windows 7 detectado: Optimizando efectos Aero...
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul
)
echo.
echo [92m[+] Ajustes visuales aplicados.[0m
pause
goto MENU

:RESTORE
cls
echo [93m[?] Iniciando Proceso de Reversion...[0m
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 1 /f >nul
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f >nul 2>&1
sc config DiagTrack start=auto >nul 2>&1
echo.
echo [92m[OK] Los valores de registro han sido restablecidos.[0m
pause
goto MENU

:TOTAL_OPTIMIZATION
cls
echo [91m[!] ALERTA: Iniciando optimizacion total del sistema.[0m
echo Esto puede tomar entre 10 a 20 minutos dependiendo de su hardware.
echo.
call :SYS_MAINTENANCE
call :STORAGE_CLEAN
call :NETWORK_PRO
call :DEBLOAT_SYSTEM
call :PRIVACY_PRO
cls
echo [92m============================================================[0m
echo    OPTIMIZACION PROFESIONAL COMPLETADA CON EXITO
echo    Se recomienda reiniciar su equipo ahora.
echo ============================================================[0m
pause
goto MENU