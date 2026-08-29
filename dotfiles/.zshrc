HISTFILE=${HOME}/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt always_to_end
setopt auto_cd
setopt complete_in_word
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_space
setopt interactivecomments

if [[ -r "${HOME}/.zsh_helpers.zsh" ]]; then
  source "${HOME}/.zsh_helpers.zsh"
else
  printf '%s\n' 'macsetup: missing ~/.zsh_helpers.zsh' >&2
fi

export BAT_THEME=gruvbox-dark
FZF_DEFAULT_OPTS='--height=60% --layout=reverse --border --info=inline'
if (( $+functions[_resolve_fzf_colorscheme] )); then
  FZF_DEFAULT_OPTS+=" $(_resolve_fzf_colorscheme)"
fi
export FZF_DEFAULT_OPTS
export FZF_DEFAULT_COMMAND="find . -path '*/.git' -prune -o -type f -print"

_zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p -- "$_zsh_cache_dir"
autoload -Uz compinit
compinit -i -d "${_zsh_cache_dir}/zcompdump"
unset _zsh_cache_dir

if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi
if (( $+commands[fnm] )); then
  source <(fnm completions --shell zsh)
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
if (( $+commands[pyenv] )); then
  eval "$(pyenv init - zsh)"
fi

_antidote_script="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
if [[ -r "$_antidote_script" ]]; then
  source "$_antidote_script"
  antidote load
else
  printf 'macsetup: Antidote missing at %s\n' "$_antidote_script" >&2
fi
unset _antidote_script

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
else
  printf '%s\n' 'macsetup: Starship is missing' >&2
fi
