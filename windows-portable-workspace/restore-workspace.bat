@echo off
setlocal EnableExtensions DisableDelayedExpansion

:: Restore a portable Windows workspace after the local profile is reset.
:: Personal paths and identity belong in restore-workspace.local.bat.

call :LOAD_CONFIG
if errorlevel 1 exit /b 1

title %WORKSPACE_TITLE%

if "%~1"=="" goto :RESTORE
if /i "%~1"=="restore" goto :RESTORE
if /i "%~1"=="capture-taskbar" goto :CAPTURE_TASKBAR
if /i "%~1"=="help" goto :USAGE
if /i "%~1"=="--help" goto :USAGE
if /i "%~1"=="/?" goto :USAGE

echo [ERROR] Unknown command: "%~1"
echo.
goto :USAGE_ERROR


:: ============================================================
:: CONFIGURATION
:: ============================================================
:LOAD_CONFIG

:: Public, non-personal defaults. Override these in the local config.
set "WORKSPACE_TITLE=Portable Workspace"
set "WORKSPACE_ROOT=E:\portable-workspace"
set "PROGRAMS_DIR="
set "TIME_ZONE_ID="
set "STARTMENU_FOLDER=Portable Workspace"
set "TASKBAR_SNAPSHOT_NAME=taskbar-v2"
set "WORKSPACE_SHORTCUT_NAME=Workspace.lnk"
set "WORKSPACE_STARTMENU_NAME=Workspace.lnk"

set "GIT_USER_NAME="
set "GIT_USER_EMAIL="

set "ENABLE_DARK_MODE=1"
set "ENABLE_TIME_ZONE=0"
set "ENABLE_PORTABLE_ENV=1"
set "ENABLE_STARTMENU=1"
set "ENABLE_TASKBAR=1"
set "ENABLE_APP_LAUNCH=1"
set "ENABLE_GIT_IDENTITY=0"
set "OPEN_DATE_TIME_SETTINGS=0"
set "OPEN_POWERSHELL_AT_END=1"

set "LOCAL_CONFIG=%~dp0restore-workspace.local.bat"
if exist "%LOCAL_CONFIG%" (
    call "%LOCAL_CONFIG%"
    echo [OK] Loaded local configuration.
) else (
    echo [WARN] Local configuration not found:
    echo        "%LOCAL_CONFIG%"
    echo        Copy restore-workspace.example.bat to that filename and edit it.
    echo.
)

if not defined WORKSPACE_ROOT (
    echo [ERROR] WORKSPACE_ROOT is not configured.
    exit /b 1
)

if not defined PROGRAMS_DIR set "PROGRAMS_DIR=%WORKSPACE_ROOT%\programs"

set "PWSH_DIR=%PROGRAMS_DIR%\PowerShell7"
set "PWSH_APP_PATH=HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\pwsh.exe"

set "STARTMENU_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%STARTMENU_FOLDER%"

set "TASKBAR_BACKUP=%WORKSPACE_ROOT%\config\%TASKBAR_SNAPSHOT_NAME%"
set "PINNED_ROOT=%APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned"
set "PINNED_BACKUP=%TASKBAR_BACKUP%\User Pinned"
set "SNAPSHOT_MARKER=%TASKBAR_BACKUP%\snapshot.ready"

set "BRAVE_SHORTCUT=%PROGRAMS_DIR%\Brave.lnk"
set "CODE_SHORTCUT=%PROGRAMS_DIR%\Code.lnk"
set "PWSH_SHORTCUT=%PROGRAMS_DIR%\pwsh.lnk"
set "WORKSPACE_SHORTCUT=%PROGRAMS_DIR%\%WORKSPACE_SHORTCUT_NAME%"
set "DITTO_EXE=%PROGRAMS_DIR%\Ditto\Ditto.exe"

exit /b 0


:: ============================================================
:: NORMAL WORKSPACE RESTORATION
:: ============================================================
:RESTORE

echo ===================================================
echo  Initializing Tools and Restoring Workspace...
echo ===================================================
echo.

if "%ENABLE_DARK_MODE%"=="1" call :SET_DARK_MODE
if "%ENABLE_TIME_ZONE%"=="1" call :SET_TIME_ZONE
if "%ENABLE_PORTABLE_ENV%"=="1" call :RESTORE_PORTABLE_ENV
if "%ENABLE_STARTMENU%"=="1" call :REGISTER_STARTMENU_SHORTCUTS
if "%ENABLE_TASKBAR%"=="1" call :RESTORE_TASKBAR
if "%ENABLE_APP_LAUNCH%"=="1" call :LAUNCH_APPS
if "%ENABLE_GIT_IDENTITY%"=="1" call :RESTORE_GIT_IDENTITY

if "%OPEN_DATE_TIME_SETTINGS%"=="1" (
    start "" "ms-settings:dateandtime"
    echo [INFO] Date and Time settings opened for manual synchronization.
)

echo.
echo ===================================================
echo  Workspace setup complete.
echo ===================================================
echo.

if "%OPEN_POWERSHELL_AT_END%"=="1" (
    if exist "%PWSH_DIR%\pwsh.exe" (
        "%PWSH_DIR%\pwsh.exe"
    ) else (
        echo [WARN] PowerShell 7 could not be launched:
        echo        "%PWSH_DIR%\pwsh.exe"
        pause
    )
)

exit /b 0


:: ============================================================
:: RESTORE STEPS
:: ============================================================
:SET_DARK_MODE

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 0 /f >nul 2>&1
if errorlevel 1 (
    echo [WARN] Windows app theme could not be changed.
    exit /b 0
)

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d 0 /f >nul 2>&1
if errorlevel 1 (
    echo [WARN] Windows system theme could not be changed.
) else (
    echo [OK] Windows appearance switched to Dark Mode.
)

exit /b 0


:SET_TIME_ZONE

if not defined TIME_ZONE_ID (
    echo [WARN] ENABLE_TIME_ZONE is on, but TIME_ZONE_ID is empty.
    exit /b 0
)

tzutil /s "%TIME_ZONE_ID%" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Could not set the time zone to "%TIME_ZONE_ID%".
) else (
    for /f "delims=" %%T in ('tzutil /g') do echo [OK] Time zone set to %%T.
)

exit /b 0


:RESTORE_PORTABLE_ENV

if exist "%PWSH_DIR%\pwsh.exe" (
    reg add "%PWSH_APP_PATH%" /ve /t REG_SZ /d "%PWSH_DIR%\pwsh.exe" /f >nul 2>&1
    reg add "%PWSH_APP_PATH%" /v Path /t REG_SZ /d "%PWSH_DIR%" /f >nul 2>&1
    echo [OK] Win + R mapping restored for PowerShell 7.
) else (
    echo [WARN] PowerShell 7 was not found:
    echo        "%PWSH_DIR%\pwsh.exe"
)

set "PORTABLE_PATHS=%PWSH_DIR%;%PROGRAMS_DIR%\Git\bin;%PROGRAMS_DIR%\Microsoft VS Code\bin;%PROGRAMS_DIR%\GitHub CLI\bin;%PROGRAMS_DIR%\Python314;%PROGRAMS_DIR%\Python314\Scripts;%PROGRAMS_DIR%\uv"
set "USER_PATH=%PORTABLE_PATHS%;%LOCALAPPDATA%\Microsoft\WindowsApps"

:: Write the user PATH directly to avoid SETX's historical truncation behavior.
reg add "HKCU\Environment" /v Path /t REG_EXPAND_SZ /d "%USER_PATH%" /f >nul 2>&1
if errorlevel 1 (
    echo [WARN] Persistent user PATH could not be updated.
) else (
    echo [OK] Persistent user PATH restored.
)

set "PATH=%PORTABLE_PATHS%;%SystemRoot%;%SystemRoot%\System32;%LOCALAPPDATA%\Microsoft\WindowsApps;%PATH%"

call :SET_USER_ENV "HOME" "%WORKSPACE_ROOT%"
call :SET_USER_ENV "PYTHONUSERBASE" "%PROGRAMS_DIR%\Python314"
call :SET_USER_ENV "UV_CACHE_DIR" "%PROGRAMS_DIR%\uv\cache"
call :SET_USER_ENV "UV_TOOL_DIR" "%PROGRAMS_DIR%\uv\tools"

set "HOME=%WORKSPACE_ROOT%"
set "PYTHONUSERBASE=%PROGRAMS_DIR%\Python314"
set "UV_CACHE_DIR=%PROGRAMS_DIR%\uv\cache"
set "UV_TOOL_DIR=%PROGRAMS_DIR%\uv\tools"

echo [OK] Portable storage variables loaded.
exit /b 0


:SET_USER_ENV

reg add "HKCU\Environment" /v "%~1" /t REG_EXPAND_SZ /d "%~2" /f >nul 2>&1
if errorlevel 1 echo [WARN] Could not persist %~1.
exit /b 0


:REGISTER_STARTMENU_SHORTCUTS

if not exist "%STARTMENU_DIR%" mkdir "%STARTMENU_DIR%" >nul 2>&1
if not exist "%STARTMENU_DIR%" (
    echo [WARN] Start Menu folder could not be created:
    echo        "%STARTMENU_DIR%"
    exit /b 0
)

call :COPY_STARTMENU_SHORTCUT "%BRAVE_SHORTCUT%" "Brave.lnk"
call :COPY_STARTMENU_SHORTCUT "%CODE_SHORTCUT%" "Code.lnk"
call :COPY_STARTMENU_SHORTCUT "%PWSH_SHORTCUT%" "PowerShell 7.lnk"
call :COPY_STARTMENU_SHORTCUT "%WORKSPACE_SHORTCUT%" "%WORKSPACE_STARTMENU_NAME%"

echo [OK] Start Menu shortcuts registered.
exit /b 0


:COPY_STARTMENU_SHORTCUT

if exist "%~1" (
    copy /y "%~1" "%STARTMENU_DIR%\%~2" >nul 2>&1
) else (
    echo [WARN] Start Menu source shortcut was not found:
    echo        "%~1"
)

exit /b 0


:RESTORE_TASKBAR

if not exist "%SNAPSHOT_MARKER%" (
    echo [WARN] Taskbar snapshot is not ready.
    echo        Arrange the taskbar, then run:
    echo        "%~f0" capture-taskbar
    exit /b 0
)

if not exist "%PINNED_BACKUP%\TaskBar" (
    echo [WARN] Taskbar shortcut backup is missing.
    exit /b 0
)

if not exist "%TASKBAR_BACKUP%\taskband.reg" (
    echo [WARN] Taskbar registry backup is missing.
    exit /b 0
)

taskkill /f /im explorer.exe >nul 2>&1

if not exist "%PINNED_ROOT%" mkdir "%PINNED_ROOT%" >nul 2>&1

:: Robocopy codes 0-7 are successful or nonfatal; 8+ means failure.
robocopy "%PINNED_BACKUP%" "%PINNED_ROOT%" /MIR /COPY:DAT /DCOPY:T /XJ /R:1 /W:1 /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 (
    echo [WARN] Taskbar shortcut data could not be restored.
    start "" explorer.exe
    exit /b 0
)

reg import "%TASKBAR_BACKUP%\taskband.reg" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Taskbar registry metadata could not be imported.
) else (
    echo [OK] Taskbar snapshot restored.
)

start "" explorer.exe
timeout /t 2 /nobreak >nul
exit /b 0


:LAUNCH_APPS

if exist "%DITTO_EXE%" (
    start "" "%DITTO_EXE%"
    echo [OK] Ditto launched.
) else (
    echo [WARN] Ditto executable was not found.
)

if exist "%BRAVE_SHORTCUT%" (
    start "" "%BRAVE_SHORTCUT%"
    echo [OK] Brave Browser launched.
) else (
    echo [WARN] Brave shortcut was not found.
)

:: Code.lnk may hold persistent --user-data-dir and --extensions-dir options.
if exist "%CODE_SHORTCUT%" (
    start "" "%CODE_SHORTCUT%"
    echo [OK] VS Code launched.
) else (
    echo [WARN] VS Code shortcut was not found.
)

exit /b 0


:RESTORE_GIT_IDENTITY

if not defined GIT_USER_NAME (
    echo [WARN] Git identity is enabled, but GIT_USER_NAME is empty.
    exit /b 0
)

if not defined GIT_USER_EMAIL (
    echo [WARN] Git identity is enabled, but GIT_USER_EMAIL is empty.
    exit /b 0
)

where git.exe >nul 2>&1
if errorlevel 1 (
    echo [WARN] Git was not found on PATH.
) else (
    git config --global user.name "%GIT_USER_NAME%"
    git config --global user.email "%GIT_USER_EMAIL%"
    echo [OK] Git identity configured.
)

exit /b 0


:: ============================================================
:: ONE-TIME TASKBAR CAPTURE
:: ============================================================
:CAPTURE_TASKBAR

if not "%ENABLE_TASKBAR%"=="1" (
    echo [ERROR] Taskbar support is disabled in the local configuration.
    exit /b 1
)

echo ===================================================
echo  Capturing Taskbar State...
echo ===================================================
echo.

if "%ENABLE_STARTMENU%"=="1" call :REGISTER_STARTMENU_SHORTCUTS

if not exist "%PINNED_ROOT%\TaskBar" (
    echo [ERROR] No live taskbar shortcut directory was found:
    echo         "%PINNED_ROOT%\TaskBar"
    pause
    exit /b 1
)

dir /b "%PINNED_ROOT%\TaskBar\*.lnk" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No pinned taskbar shortcuts were found.
    echo         Pin apps from "%STARTMENU_FOLDER%" first.
    pause
    exit /b 1
)

dir /b "%PINNED_ROOT%\TaskBar\* (2).lnk" >nul 2>&1
if not errorlevel 1 (
    echo [ERROR] Duplicate taskbar shortcuts ending in "(2)" were found.
    echo         Clean the live taskbar before creating this snapshot.
    pause
    exit /b 1
)

if not exist "%TASKBAR_BACKUP%" mkdir "%TASKBAR_BACKUP%" >nul 2>&1
if not exist "%PINNED_BACKUP%" mkdir "%PINNED_BACKUP%" >nul 2>&1

:: Remove the marker first so interrupted captures cannot be restored.
del /q "%SNAPSHOT_MARKER%" >nul 2>&1

robocopy "%PINNED_ROOT%" "%PINNED_BACKUP%" /MIR /COPY:DAT /DCOPY:T /XJ /R:1 /W:1 /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 (
    echo [ERROR] Taskbar shortcut data could not be captured.
    pause
    exit /b 1
)

if not exist "%PINNED_BACKUP%\TaskBar\*.lnk" (
    echo [ERROR] Capture completed without copying taskbar shortcuts.
    pause
    exit /b 1
)

attrib -h -s "%PINNED_BACKUP%" >nul 2>&1
attrib -h -s "%PINNED_BACKUP%\*" /s /d >nul 2>&1

reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" "%TASKBAR_BACKUP%\taskband.reg" /y >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Taskbar registry metadata could not be exported.
    pause
    exit /b 1
)

> "%SNAPSHOT_MARKER%" echo taskbar-v2-startmenu

echo [OK] Taskbar snapshot saved to:
echo      "%TASKBAR_BACKUP%"
echo.
echo Run this file normally after the next profile reset:
echo      "%~f0"
echo.
pause
exit /b 0


:: ============================================================
:: HELP
:: ============================================================
:USAGE

echo Usage:
echo   %~nx0                 Restore the configured workspace
echo   %~nx0 restore         Restore the configured workspace
echo   %~nx0 capture-taskbar Capture the current Windows 10 taskbar
echo   %~nx0 help            Show this help
exit /b 0


:USAGE_ERROR
call :USAGE
exit /b 2
