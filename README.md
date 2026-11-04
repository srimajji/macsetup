# macsetup

## What it does

Applies the packages in `Brewfile`, links the managed Zsh, Git, Starship, and Neovim configuration into the home directory, installs Antidote plugins, selects Homebrew Zsh as the login shell, installs the latest Node LTS with fnm, and installs the latest stable Python 3 with uv. Application sign-in remains manual; this repository never stores credentials.

## First machine setup

Finish macOS Setup Assistant, connect to the internet, and open Terminal. Then download and run the public bootstrap:

```bash
curl -fsSL https://raw.githubusercontent.com/srimajji/macsetup/main/bootstrap -o /tmp/macsetup-setup
/bin/bash /tmp/macsetup-setup
```

The downloaded bootstrap always clones or fast-forwards to the latest public `main` commit in `${HOME}/.macsetup`, then runs its `setup`. If Command Line Tools opens and the script exits `2`, complete the installer and rerun only:

```bash
/bin/bash /tmp/macsetup-setup
```

Complete Homebrew, cask, and login-shell password or approval prompts. Open a new Terminal and run `${HOME}/.macsetup/doctor`.

After signing in to 1Password, create the encrypted, case-sensitive `Dev` volume for code at `/Volumes/Dev` (with `personal` and `work` folders). Paste the volume password from 1Password when prompted, and let macOS remember it in the keychain when it first asks at login:

```bash
"$HOME/.macsetup/dev-volume"
```

## Commands

`Brewfile` is the authoritative CLI and cask inventory. `.zsh_helpers.zsh` contains the shell helper implementations.

| Command | Purpose |
| --- | --- |
| `${HOME}/.macsetup/setup` | Apply packages and configuration |
| `${HOME}/.macsetup/post-install` | Install and default the latest Node LTS and Python 3 |
| `${HOME}/.macsetup/doctor` | Run read-only verification |
| `${HOME}/.macsetup/dev-volume` | Create the encrypted `/Volumes/Dev` code volume |
| `brew bundle check --file "$HOME/.macsetup/Brewfile" --verbose` | Verify the package contract |
| `fnm list` | List installed Node versions |
| `fnm use <version>` | Activate an installed Node version |
| `fnm install --lts` | Install the latest Node LTS |
| `uv python list --only-installed` | List installed Python versions |
| `uv python pin <version>` | Pin a Python version for the current project |
| `macsetup status --short` | Show concise checkout changes |
| `macsetup diff` | Review checkout changes |

Setup intentionally uses `brew bundle --no-upgrade`. Upgrade only Zsh and required dependencies explicitly:

```bash
brew update
brew upgrade zsh
"$HOME/.macsetup/doctor"
exec /opt/homebrew/bin/zsh -l
```

| Shell helpers | Purpose |
| --- | --- |
| `..`, `...`, `....`, `.....` | Navigate to parent directories |
| `g`, `macsetup` | Run Git in the current or installed setup checkout |
| `c`, `ccd`, `path` | Copy input, copy the current path, or print `PATH` entries |
| `ls`, `l`, `la`, `lsd`, `lst` | List files and directories with eza |
| `f`, `v` | Select a file with fzf or open the selection in Neovim |
| `mkd`, `o` | Create and enter a directory or open a path |
| `refresh`, `reload` | Source `.zshrc` or replace the shell with login Zsh |

## Updating configuration

Six managed home paths are symbolic links into the writable `${HOME}/.macsetup` checkout. `~/.zprofile`, `~/.zshrc`, and `~/.gitconfig` are instead small machine-local loaders that load `dotfiles/.zprofile`, `dotfiles/.zshrc`, and `dotfiles/.gitconfig`, so installers and `git config --global` can write to them without changing the repository. Edit the shared configuration under `${HOME}/.macsetup/dotfiles/`. Because `~/.gitconfig` uses `[include]`, add `--includes` when reading a shared value with `git config --global`. For a checkout already on `main`:

```bash
macsetup status --short
"$EDITOR" "$HOME/.zsh_helpers.zsh"
macsetup diff -- dotfiles/.zsh_helpers.zsh
macsetup add dotfiles/.zsh_helpers.zsh
macsetup commit -m "Update Zsh configuration"
macsetup push origin main
```

On the first push from a reset machine, authenticate interactively with `gh auth login --web --git-protocol https`, then run `gh auth setup-git`. Bootstrap itself is credential-free. Never reset or switch branches with uncommitted changes.

Edit repository-owned, non-linked files such as `Brewfile`, `setup`, and `doctor` under `${HOME}/.macsetup`; run `${HOME}/.macsetup/setup`, review `macsetup diff`, commit, and push. To adopt another configuration file, place it under `dotfiles/` at its home-relative path, add the corresponding setup link and doctor assertion, run setup, then commit the complete change.

## References

- [Homebrew installation](https://docs.brew.sh/Installation)
- [Brew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile)
- [Antidote](https://antidote.sh/)
- [fnm](https://github.com/Schniz/fnm/tree/master)
- [Starship configuration](https://starship.rs/config/)
