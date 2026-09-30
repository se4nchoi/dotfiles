@echo off

:: Copy this file to restore-workspace.local.bat and edit the values.
:: The local file is gitignored because it may contain personal information.

set "WORKSPACE_TITLE=Portable Classroom Workspace"
set "WORKSPACE_ROOT=E:\portable-workspace"
set "PROGRAMS_DIR=%WORKSPACE_ROOT%\programs"

set "TIME_ZONE_ID=Korea Standard Time"
set "STARTMENU_FOLDER=Portable Workspace"
set "TASKBAR_SNAPSHOT_NAME=taskbar-v2"
set "WORKSPACE_SHORTCUT_NAME=Workspace.lnk"
set "WORKSPACE_STARTMENU_NAME=Workspace.lnk"

:: Optional overrides for developer CLIs (defaults shown).
:: set "NODE_DIR=%PROGRAMS_DIR%\nodejs"
:: set "CODEX_DIR=%PROGRAMS_DIR%\codex\bin"
:: set "CLAUDE_DIR=%PROGRAMS_DIR%\claude\bin"
:: set "CODEX_HOME_DIR=%WORKSPACE_ROOT%\.codex-home"
:: set "CLAUDE_HOME_DIR=%WORKSPACE_ROOT%\.claude-home"

set "GIT_USER_NAME=Your Name"
set "GIT_USER_EMAIL=you@example.com"

:: Feature switches: 1 = enabled, 0 = disabled.
set "ENABLE_DARK_MODE=1"
set "ENABLE_TIME_ZONE=1"
set "ENABLE_PORTABLE_ENV=1"
set "ENABLE_STARTMENU=1"
set "ENABLE_TASKBAR=1"
set "ENABLE_APP_LAUNCH=1"
set "ENABLE_GIT_IDENTITY=1"
set "OPEN_DATE_TIME_SETTINGS=1"
set "OPEN_POWERSHELL_AT_END=1"
