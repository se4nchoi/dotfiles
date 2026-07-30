# Dotfiles for Git Configuration

### Disclaimer

This repository is primarily meant to track my own Git configuration and preferences across machines, with aliases and setup script.

If you want to use it for your own setup, treat it as a starting point, fork or copy it into your own repository, and update your own identity and personal Git settings accordingly.

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

## Fresh-machine setup

1. Install the prerequisites above.

2. Clone/fork this repository into your home directory:

   ```bash
   git clone https://github.com/<your-username>/dotfiles.git
   cd ~/dotfiles
   ```

   If you are using a local copy, replace the URL with the appropriate path or repository address.

3. Run the setup script:

   ```bash
   bash setup.sh
   ```

4. When prompted, enter:
   - your full name
   - your email address

   These values are stored in ~/.gitconfig-private so your identity stays local to your machine.

5. If you plan to push or pull from GitHub over HTTPS, authenticate GitHub CLI:

   ```bash
   gh auth login
   ```

6. Verify that Git is picking up the expected config:

   ```bash
   git config --global --get include.path
   ```

## What the setup does

The script performs these steps:

- creates ~/.gitconfig-private if it does not already exist
- backs up an existing ~/.gitconfig to ~/.gitconfig.bak if necessary
- replaces the global Git config with a symlink to this repository’s [.gitconfig](.gitconfig)

## Personal use note

This repository is primarily meant to track my own Git configuration and preferences across machines.

If someone else wants to use it for their own setup, they should treat it as a starting point and either:

- fork or copy the repository into their own GitHub account/repo, and
- update their own identity and any personal Git settings accordingly

This repo is not intended to be a shared, multi-user dotfiles project by default.

## GitHub authentication note

The setup itself does not require GitHub authentication. However, if you want GitHub operations such as `git push` or `git pull` to work smoothly, you will need either:

- GitHub CLI installed and logged in with `gh auth login`, or
- another Git credential helper configured for your environment

The shared config uses GitHub CLI for GitHub HTTPS credential handling.

## Included Git aliases

The shared config includes helpful aliases such as:

- `graph`
- `cm`
- `st`
- `sw`
- `cb`
- `recom`
- `uncom`
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
- The setup script currently assumes the repository is located at ~/dotfiles. If you clone it somewhere else, update the `DOTFILES_DIR` path in [setup.sh](setup.sh).

## Troubleshooting

If Git is still using an old config, re-run the setup script after reviewing your current Git configuration.
