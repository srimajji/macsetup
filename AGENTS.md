# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## What this is

A personal macOS bootstrap and dotfiles repo for Apple Silicon running macOS 26 or later. There is no build step. The product is five Bash scripts, the `bin/macsetup` dispatcher, and the config files they link into `$HOME`. The installed checkout lives at `${HOME}/.macsetup`. Most managed home files are symlinks into it, so editing `~/.zsh_helpers.zsh` edits `dotfiles/.zsh_helpers.zsh`. `~/.zprofile`, `~/.zshrc`, and `~/.gitconfig` are the exception: they are machine-local loader files that `source` (Zsh) or `[include]` (Git) the repo copies. Edit `dotfiles/.zshrc` and `dotfiles/.gitconfig`, not the files in `~`. The global Git ignore file is `dotfiles/.config/git/ignore`, linked to Git's default `~/.config/git/ignore`; there is no `core.excludesFile`.

## Validation (mirrors `.github/workflows/validate.yml`)

Run these from the repo root before committing. CI runs them on `macos-26`.

```bash
bash -n bootstrap setup post-install doctor dev-volume bin/macsetup
shellcheck -s bash bootstrap setup post-install doctor dev-volume bin/macsetup
/opt/homebrew/bin/zsh -n dotfiles/.zprofile dotfiles/.zshrc dotfiles/.zsh_helpers.zsh
STARSHIP_CONFIG="$PWD/dotfiles/.config/starship.toml" starship print-config >/dev/null
XDG_CONFIG_HOME="$PWD/dotfiles/.config" /opt/homebrew/bin/nvim --headless '+qall'
```

- `./doctor` runs a read-only check of the live machine: platform, Homebrew, account shell, Brewfile, symlinks and loaders, fnm/Node LTS, Antidote bundle, helpers, and Neovim. It prints PASS/FAIL/SKIP/WARN lines and exits 1 on any failure.
- `./setup` is the real apply step. It is idempotent, but it changes the machine: it runs `brew bundle`, rewrites symlinks, may run `sudo` to edit `/etc/shells`, and runs `chsh`. Don't run it unless the user asks.
- Set `MAC_SETUP_SKIP_ACCOUNT_SHELL=1` to skip the `/etc/shells` and `chsh` steps in both `setup` and `doctor`. Any value other than unset or `1` exits 64.

## Flow and invariants

`bootstrap` → `setup` → `post-install` → `doctor` (`setup` `exec`s `doctor` at the end).

- **bootstrap** is meant to be downloaded with curl, so it has no repo-relative dependencies. It checks the platform and installs Command Line Tools (exit 2 means "finish the CLT installer, then rerun"). It then installs Homebrew and clones `main`, or fast-forwards it with `--ff-only`. It refuses to continue on a dirty tree, a detached HEAD, a branch other than `main`, or an unexpected origin.
- **setup** links each managed file through `backup_and_link`. For `~/.zprofile`, `~/.zshrc`, and `~/.gitconfig` it uses `write_loader` instead, which writes a small file containing the given loader line (`source "<repo>/dotfiles/<file>"` or `[include] path = "<repo>/dotfiles/.gitconfig"`) and leaves an existing loader (and any lines appended below it) alone. `doctor`'s `check_loader` asserts that exact line. In both cases an existing non-matching file is moved to `~/.macsetup-backups/<UTC timestamp>/` first. Brew runs with `--no-upgrade` on purpose, so upgrades stay manual.
- **post-install** installs the latest Node LTS with fnm and the latest stable Python 3 with `uv python install --default`, which downloads a prebuilt Python and links `python` and `python3` into `~/.local/bin`. It makes both the defaults. CI runs it against a temporary `HOME`, `FNM_DIR`, `XDG_BIN_HOME`, and `XDG_DATA_HOME`.
- **bin/macsetup** is linked to `~/.local/bin/macsetup`. `macsetup setup|post-install|doctor|dev-volume` runs that script from the checkout, and every other argument list is passed to `git -C <checkout>`, so `macsetup status` and `macsetup push origin main` work. It resolves its own symlink with `readlink -f` to find the checkout. It replaced the old `macsetup` Zsh alias, so do not add that alias back; it would shadow the command.
- **dev-volume** is run by hand after 1Password sign-in, outside the setup chain. It creates the encrypted, case-sensitive `Dev` APFS volume at `/Volumes/Dev` with `diskutil apfs addVolume -passprompt`, then creates `personal/` and `work/`. It is a no-op when the volume is already mounted. `doctor` warns (not fails) when Dev is missing. Never pass the volume password as an argument.

**Adding a managed dotfile requires three coordinated edits:** put the file under `dotfiles/` at its home-relative path, add a `backup_and_link` line in `setup`, and add a `check_managed_link` line in `doctor`. The README says "Seven managed home paths", so update that count too. Use `write_loader` and `check_loader` instead for files that installers are known to edit.

**CI enforces several exact contracts.** Change them together or CI fails:
- **Brewfile formulae and casks** must match the two sorted lists hard-coded in `validate.yml`. Adding or removing a package means editing both files.
- **Required helpers** (`c ccd _resolve_fzf_colorscheme f v mkd o`, the `ls` alias containing `eza -l --icons=auto`) are asserted in both `validate.yml` and `doctor`. CI also runs `bin/macsetup` through a symlink and checks that it reaches the checkout.
- **Antidote plugins** in `dotfiles/.zsh_plugins.txt` are asserted line by line in `doctor`'s `expected_plugins`. `dotfiles/.zsh_plugins.zsh` is generated and gitignored.

## Script conventions

- Bash scripts start with `set -euo pipefail` (`doctor` uses `set -uo pipefail` so it keeps going after a failure). They call system binaries by absolute path (`/usr/bin/git`, `/bin/mv`, `/opt/homebrew/bin/...`). They reject arguments with `usage: <name>` and exit 64. Errors go through `die` with a `macsetup <script>:` prefix.
- Scripts stay shellcheck-clean. When a single-quoted string is meant to expand inside a child Zsh, add `# shellcheck disable=SC2016` with a comment explaining why.
- Neovim uses the built-in `vim.pack` plugin manager, and plugin versions are pinned in `nvim-pack-lock.json`.

## Gotchas

- Third-party installers such as Docker Desktop and LM Studio append to `~/.zprofile` and `~/.zshrc`, and some rewrite the whole file. `gh auth setup-git` and `git lfs install` write to `~/.gitconfig`. That is why those three are loaders rather than symlinks: installer lines stay machine-local. If installer lines with hard-coded `/Users/<name>` paths appear in `dotfiles/`, point them out instead of committing them.
- Never store credentials in this repo. It is public, and bootstrap is intentionally credential-free.
- Commit to `main` and push with `macsetup push origin main` (`macsetup` passes Git commands to `~/.macsetup`). Don't reset or switch branches while there are uncommitted changes. Bootstrap refuses to run in that state.
