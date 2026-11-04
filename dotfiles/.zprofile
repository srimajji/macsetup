if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

export EDITOR=nvim
export VISUAL=nvim
export LANG=en_US.UTF-8

typeset -U path PATH
path=("${HOME}/.local/bin" $path)
if [[ -d /opt/homebrew/opt/curl/bin ]]; then
  path=(/opt/homebrew/opt/curl/bin $path)
fi

_onepassword_agent="${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
if [[ -S "$_onepassword_agent" ]]; then
  export SSH_AUTH_SOCK="$_onepassword_agent"
fi
unset _onepassword_agent
