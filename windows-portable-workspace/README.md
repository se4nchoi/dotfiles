# Windows portable workspace restore

`restore-workspace.bat` rebuilds a portable development environment after a
Windows user profile is reset. It was written for classroom PCs where the
system drive is reimaged but a secondary drive remains persistent.

It can:

- enable Windows dark mode;
- set a configured Windows time zone;
- restore user-level `PATH` and portable Python/uv environment variables;
- register portable application shortcuts in the Start Menu;
- capture and restore Windows 10 taskbar pins;
- launch Ditto, Brave, VS Code, and PowerShell 7;
- restore an optional global Git identity; and
- open Date & Time settings for manual clock synchronization.

## Requirements

- Windows 10
- a persistent drive or directory
- portable applications arranged under a `programs` directory
- `robocopy`, `reg`, `tzutil`, and `taskkill` from Windows

The expected default layout is:

```text
E:\portable-workspace\
├── config\
│   └── taskbar-v2\       created by capture-taskbar
└── programs\
    ├── Brave.lnk
    ├── Code.lnk
    ├── Ditto\Ditto.exe
    ├── Git\bin\
    ├── GitHub CLI\bin\
    ├── Microsoft VS Code\bin\
    ├── PowerShell7\pwsh.exe
    ├── Python314\
    ├── pwsh.lnk
    ├── uv\
    └── Workspace.lnk
```

`Code.lnk` can include portable VS Code arguments such as
`--user-data-dir` and `--extensions-dir`.

Shortcut filenames can be adapted in the local configuration. For example, a
source named `my-workspace-folder.lnk` can still be registered in the Start Menu
as `Workspace.lnk`.

## Setup

1. Copy the example configuration:

   ```bat
   copy restore-workspace.example.bat restore-workspace.local.bat
   ```

2. Edit `restore-workspace.local.bat` for your drive, time zone, feature
   switches, and optional Git identity.

3. Run the restore:

   ```bat
   restore-workspace.bat
   ```

The local configuration is intentionally ignored by Git.

## Taskbar capture

Taskbar restore is specific to the Windows 10 profile and application paths
where it was captured.

1. Run the normal restore once so the Start Menu shortcuts exist.
2. Pin those shortcuts to the taskbar and arrange them.
3. Remove any duplicate shortcuts ending in `(2)`.
4. Capture the state:

   ```bat
   restore-workspace.bat capture-taskbar
   ```

The snapshot is stored under
`%WORKSPACE_ROOT%\config\%TASKBAR_SNAPSHOT_NAME%`. Do not publish it: shortcut
targets and exported registry data may reveal local paths and profile details.

During restore, Explorer is restarted before the shortcuts and Taskband
registry data are applied. Open File Explorer windows may close.

## Commands

```text
restore-workspace.bat
restore-workspace.bat restore
restore-workspace.bat capture-taskbar
restore-workspace.bat help
```

## Notes

- The script writes only user-level registry and environment settings, but
  setting the time zone may be blocked by organization policy.
- The user `PATH` is written through `HKCU\Environment` to avoid the historical
  length truncation associated with `setx`.
- Taskbar internals changed in Windows 11, so the capture/restore workflow is
  documented and supported here only for Windows 10.
- Safety-critical or shared computers should be reviewed before enabling
  taskbar restoration, global Git identity, or application auto-launch.
