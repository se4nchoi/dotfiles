# Windows portable workspace restore

`restore-workspace.bat` rebuilds a portable development environment after a
Windows user profile is reset. It was written for classroom PCs where the
system drive is reimaged but a secondary drive remains persistent.

It can:

- enable Windows dark mode;
- set a configured Windows time zone;
- restore user-level `PATH` and portable Python/uv/npm environment variables;
- keep Node.js, Codex CLI, and Claude Code on the persistent drive, with
  their config and auth in `.codex-home` and `.claude-home`;
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
├── .claude-home\         CLAUDE_CONFIG_DIR
├── .codex-home\          CODEX_HOME
├── config\
│   └── taskbar-v2\       created by capture-taskbar
└── programs\
    ├── Brave.lnk
    ├── claude\bin\claude.exe
    ├── Code.lnk
    ├── codex\bin\codex.exe
    ├── Ditto\Ditto.exe
    ├── Git\bin\
    ├── GitHub CLI\bin\
    ├── Microsoft VS Code\bin\
    ├── nodejs\           npm globals and npm-cache live here too
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

## Node.js, Codex, and Claude Code

- **Node.js**: copy an installed `C:\Program Files\nodejs` (or extract the
  zip distribution) to `programs\nodejs`. `NPM_CONFIG_PREFIX` points there, so
  `npm install -g` puts commands beside `node.exe` on `PATH`.
- **Codex**: place the standalone `codex.exe` in `programs\codex\bin`.
- **Claude Code**: run `update-claude.ps1 -WorkspaceRoot E:\portable-workspace`.
  It installs or upgrades the winget package and copies `claude.exe` into
  `programs\claude\bin`. Claude's own auto-updater is disabled because it
  installs into the reset profile; rerun the script to update.

To move existing logins, copy `%USERPROFILE%\.codex` to `.codex-home` and
`%USERPROFILE%\.claude` plus `%USERPROFILE%\.claude.json` into `.claude-home`.

## Brave as the default browser

`Brave.lnk` opens Brave with `--user-data-dir`, but the handlers Brave
registers for http, https, and `.html` do not include it, so links opened from
other apps start a blank profile. With `BRAVE_USER_DATA_DIR` set, the restore
rewrites those handlers to use the persistent profile. If Brave was not
registered yet during restore, set it as the default browser and run:

```bat
restore-workspace.bat fix-brave
```

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
restore-workspace.bat fix-brave
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
