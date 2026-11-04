# macsetup

## What it does

Applies the packages in `Brewfile`, links the managed Zsh, Git, Starship, and Neovim configuration into the home directory, installs Antidote plugins, selects Homebrew Zsh as the login shell, installs the latest Node LTS with fnm, and installs the latest stable Python 3 with uv. Application sign-in remains manual; this repository never stores credentials.

## First machine setup

Requires an Apple Silicon Mac on macOS 26 or later. Run these steps in order.

1. Finish macOS Setup Assistant, connect to the internet, and open Terminal.
2. Download and run the public bootstrap:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/srimajji/macsetup/main/bootstrap -o /tmp/macsetup-setup
   /bin/bash /tmp/macsetup-setup
   ```

   If the Command Line Tools installer opens and the script exits `2`, complete the installer and rerun only the second line. Stay nearby to answer Homebrew, cask, and login-shell password or approval prompts.

   Bootstrap installs Command Line Tools and Homebrew, clones the latest public `main` into `${HOME}/.macsetup`, and runs `setup`. `setup` installs the `Brewfile`, writes the Zsh and Git loaders and config links, installs the `macsetup` command in `~/.local/bin`, switches the login shell to Homebrew Zsh, generates Antidote plugins, starts Neovim once to install its plugins, then runs `post-install` (Node LTS with fnm and Python 3 with uv) and `doctor`.
3. Open a new Terminal window so it starts Homebrew Zsh with the managed configuration, then verify:

   ```bash
   macsetup doctor
   ```

   Expect one warning until step 6: `/Volumes/Dev is not mounted`.
4. Open 1Password, sign in, and turn on its SSH agent (Settings → Developer). `.zprofile` already points `SSH_AUTH_SOCK` at it.
5. Sign in to GitHub so you can push from `${HOME}/.macsetup`:

   ```bash
   gh auth login --web --git-protocol https
   gh auth setup-git
   ```
6. Create the encrypted, case-sensitive `Dev` volume for code at `/Volumes/Dev`, with `personal` and `work` folders. Paste the volume password from 1Password at the prompts. When macOS later asks for it at login, choose to remember it in the keychain:

   ```bash
   macsetup dev-volume
   ```
7. Move Spotlight off ⌘ Space before giving it to Raycast: in System Settings → Keyboard → Keyboard Shortcuts → Spotlight, set "Show Spotlight search" to ⌥ Space. Then open Raycast and choose ⌘ Space as its hotkey during onboarding, or restore your Raycast settings.
8. Install oMLX from the macOS 26 DMG on its [releases page](https://github.com/jundot/omlx/releases), open it once to choose a model folder, and let it add its CLI to `~/.zshrc`.
9. Sign in to the remaining apps, and open Docker Desktop once to finish its setup.

### If a step fails

Fix the cause and rerun; every step skips work that is already done. Before the repository is cloned, rerun `/bin/bash /tmp/macsetup-setup`, or both bootstrap lines after a restart, because macOS clears `/tmp`. After the clone, run `"$HOME/.macsetup/setup"` directly, or `macsetup setup` once the command is installed. Bootstrap refuses to run while `${HOME}/.macsetup` has uncommitted changes, so commit them or run `setup` directly. Files that `setup` replaces are moved to `~/.macsetup-backups/<timestamp>/`.

## Commands

`Brewfile` is the authoritative CLI and cask inventory. `.zsh_helpers.zsh` contains the shell helper implementations.

| Command | Purpose |
| --- | --- |
| `macsetup setup` | Apply packages and configuration |
| `macsetup post-install` | Install and default the latest Node LTS and Python 3 |
| `macsetup doctor` | Run read-only verification |
| `macsetup dev-volume` | Create the encrypted `/Volumes/Dev` code volume |
| `macsetup <git command>` | Run Git in the setup checkout, such as `macsetup status` or `macsetup push origin main` |
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
macsetup doctor
exec /opt/homebrew/bin/zsh -l
```

| Shell helpers | Purpose |
| --- | --- |
| `..`, `...`, `....`, `.....` | Navigate to parent directories |
| `g` | Run Git in the current directory |
| `c`, `ccd`, `path` | Copy input, copy the current path, or print `PATH` entries |
| `ls`, `l`, `la`, `lsd`, `lst` | List files and directories with eza |
| `f`, `v` | Select a file with fzf or open the selection in Neovim |
| `mkd`, `o` | Create and enter a directory or open a path |
| `refresh`, `reload` | Source `.zshrc` or replace the shell with login Zsh |

## Updating configuration

Seven managed home paths are symbolic links into the writable `${HOME}/.macsetup` checkout. `~/.zprofile`, `~/.zshrc`, and `~/.gitconfig` are instead small machine-local loaders that load `dotfiles/.zprofile`, `dotfiles/.zshrc`, and `dotfiles/.gitconfig`, so installers and `git config --global` can write to them without changing the repository. Edit the shared configuration under `${HOME}/.macsetup/dotfiles/`. Because `~/.gitconfig` uses `[include]`, add `--includes` when reading a shared value with `git config --global`. For a checkout already on `main`:

```bash
macsetup status --short
"$EDITOR" "$HOME/.zsh_helpers.zsh"
macsetup diff -- dotfiles/.zsh_helpers.zsh
macsetup add dotfiles/.zsh_helpers.zsh
macsetup commit -m "Update Zsh configuration"
macsetup push origin main
```

Pushing requires the GitHub sign-in from step 5 of First machine setup. Bootstrap itself is credential-free. Never reset or switch branches with uncommitted changes.

Edit repository-owned, non-linked files such as `Brewfile`, `setup`, and `doctor` under `${HOME}/.macsetup`; run `macsetup setup`, review `macsetup diff`, commit, and push. To adopt another configuration file, place it under `dotfiles/` at its home-relative path, add the corresponding setup link and doctor assertion, run setup, then commit the complete change.

## References

- [Homebrew installation](https://docs.brew.sh/Installation)
- [Brew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile)
- [Antidote](https://antidote.sh/)
- [fnm](https://github.com/Schniz/fnm/tree/master)
- [Starship configuration](https://starship.rs/config/)
