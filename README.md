# Dotfiles for Git Configuration

This repository contains a small, portable Git configuration setup that can be installed on a new machine with a single script.

## What this repo includes

- A shared Git config in [.gitconfig](.gitconfig)
- A setup script, [setup.sh](setup.sh), that:
  - creates a private Git identity file at ~/.gitconfig-private
  - backs up any existing global ~/.gitconfig if needed
  - links ~/.gitconfig to this repository’s config

## Requirements

Make sure these are available before running the setup:

- Git
- Bash
- GitHub CLI (`gh`) if you want the configured GitHub credential helper to work

## Quick start

1. Clone the repository:

   ```bash
   git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the setup script:

   ```bash
   bash setup.sh
   ```

3. The script will prompt you for:
   - your full name
   - your email address

   These values are stored in ~/.gitconfig-private so your identity stays local to your machine.

4. If you use GitHub CLI, authenticate it:

   ```bash
   gh auth login
   ```

## What the setup does

The script performs the following steps:

- creates ~/.gitconfig-private if it does not already exist
- backs up an existing ~/.gitconfig to ~/.gitconfig.bak if necessary
- replaces the global Git config with a symlink to this repository’s [.gitconfig](.gitconfig)

## Included Git aliases

The shared config includes helpful aliases such as:

- `graph`
- `cm`
- `st`
- `sw`
- `cb`
- `rcom`
- `ucom`
- `up`
- `sync`
- `pub`

## Optional: enable AI-assisted Git aliases

The config contains commented examples for optional aliases such as `ai-msg` and `ai-commit`. These are currently disabled by default.

To enable them, install your preferred AI Git helper and point the alias to the correct executable, for example:

```bash
~/.local/bin/git-ai-msg
```

Then uncomment the relevant lines in [.gitconfig](.gitconfig).

## Notes

- If a real ~/.gitconfig already exists, it will be backed up instead of overwritten.
- The private identity file is intentionally kept separate from the version-controlled config.

## Troubleshooting

If Git is still using an old config, you can verify the active config path:

```bash
git config --global --get include.path
```

If needed, re-run the setup script after reviewing your current Git configuration.
