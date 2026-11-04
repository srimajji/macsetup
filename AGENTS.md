# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## What this is

A personal macOS bootstrap and dotfiles repo for Apple Silicon running macOS 26 or later. There is no build step. The product is four Bash entry points plus the config files they link into `$HOME`. The installed checkout lives at `${HOME}/.macsetup`, and the managed home files are symlinks into it. Editing `~/.zshrc` therefore edits `dotfiles/.zshrc` in this repo.

## Validation (mirrors `.github/workflows/validate.yml`)

Run these from the repo root before committing. CI runs them on `macos-26`.

```bash
bash -n bootstrap setup post-install doctor
shellcheck -s bash bootstrap setup post-install doctor
/opt/homebrew/bin/zsh -n dotfiles/.zprofile dotfiles/.zshrc dotfiles/.zsh_helpers.zsh
STARSHIP_CONFIG="$PWD/dotfiles/.config/starship.toml" starship print-config >/dev/null
XDG_CONFIG_HOME="$PWD/dotfiles/.config" /opt/homebrew/bin/nvim --headless '+qall'
```

- `./doctor` runs a read-only check of the live machine: platform, Homebrew, account shell, Brewfile, symlinks, fnm/Node LTS, Antidote bundle, helpers, and Neovim. It prints PASS/FAIL/SKIP/WARN lines and exits 1 on any failure.
- `./setup` is the real apply step. It is idempotent, but it changes the machine: it runs `brew bundle`, rewrites symlinks, may run `sudo` to edit `/etc/shells`, and runs `chsh`. Don't run it unless the user asks.
- Set `MAC_SETUP_SKIP_ACCOUNT_SHELL=1` to skip the `/etc/shells` and `chsh` steps in both `setup` and `doctor`. Any value other than unset or `1` exits 64.

## Flow and invariants

`bootstrap` → `setup` → `post-install` → `doctor` (`setup` `exec`s `doctor` at the end).

- **bootstrap** is meant to be downloaded with curl, so it has no repo-relative dependencies. It checks the platform and installs Command Line Tools (exit 2 means "finish the CLT installer, then rerun"). It then installs Homebrew and clones `main`, or fast-forwards it with `--ff-only`. It refuses to continue on a dirty tree, a detached HEAD, a branch other than `main`, or an unexpected origin.
- **setup** links each managed file through `backup_and_link`. An existing non-matching file is moved to `~/.macsetup-backups/<UTC timestamp>/` first. Brew runs with `--no-upgrade` on purpose, so upgrades stay manual.
- **post-install** installs the latest Node LTS with fnm and makes it the default.

**Adding a managed dotfile requires three coordinated edits:** put the file under `dotfiles/` at its home-relative path, add a `backup_and_link` line in `setup`, and add a `check_managed_link` line in `doctor`. The README calls these "seven managed home paths", so update that count too.

**CI enforces several exact contracts.** Change them together or CI fails:
- **Brewfile formulae and casks** must match the two sorted lists hard-coded in `validate.yml`. Adding or removing a package means editing both files.
- **Required helpers** (`c ccd _resolve_fzf_colorscheme f v mkd o`, the `ls` alias containing `eza -l --icons=auto`, and the `macsetup` alias pointing at `$HOME/.macsetup`) are asserted in both `validate.yml` and `doctor`.
- **Antidote plugins** in `dotfiles/.zsh_plugins.txt` are asserted line by line in `doctor`'s `expected_plugins`. `dotfiles/.zsh_plugins.zsh` is generated and gitignored.

## Script conventions

- Bash scripts start with `set -euo pipefail` (`doctor` uses `set -uo pipefail` so it keeps going after a failure). They call system binaries by absolute path (`/usr/bin/git`, `/bin/mv`, `/opt/homebrew/bin/...`). They reject arguments with `usage: <name>` and exit 64. Errors go through `die` with a `macsetup <script>:` prefix.
- Scripts stay shellcheck-clean. When a single-quoted string is meant to expand inside a child Zsh, add `# shellcheck disable=SC2016` with a comment explaining why.
- Neovim uses the built-in `vim.pack` plugin manager, and plugin versions are pinned in `nvim-pack-lock.json`.

## Gotchas

- Third-party installers such as Docker Desktop and LM Studio append to `~/.zprofile` and `~/.zshrc`. Because those are symlinks, the changes appear as uncommitted diffs here, often with hard-coded `/Users/<name>` paths. Point these out instead of committing them silently.
- Never store credentials in this repo. It is public, and bootstrap is intentionally credential-free.
- Commit to `main` and push with `macsetup push origin main` (`macsetup` is an alias for `git -C ~/.macsetup`). Don't reset or switch branches while there are uncommitted changes. Bootstrap refuses to run in that state.
