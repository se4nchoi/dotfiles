# dotfiles

Personal configuration and setup automation, split by machine/tool since
each piece has its own audience and lifecycle. Each subfolder is
self-contained with its own README and setup instructions — start there.

## Contents

- [`git/`](./git) — shared Git configuration, aliases, and a setup script
  that links a portable `.gitconfig` and keeps identity local per machine.
- [`windows-portable-workspace/`](./windows-portable-workspace) — restores
  a portable Windows development environment (PATH, shortcuts, taskbar,
  portable apps) after a classroom/lab PC profile reset.

## Usage

Clone the whole repo, then follow the README inside whichever subfolder
applies to your machine. Nothing here assumes both components are used
together.

```bash
git clone https://github.com/se4nchoi/dotfiles.git
cd dotfiles
```

## Disclaimer

This repository tracks my own configuration and preferences across
machines. If you're using any part of it for your own setup, treat it as
a starting point: fork or copy the relevant subfolder and update the
identity/personal values for your own environment.