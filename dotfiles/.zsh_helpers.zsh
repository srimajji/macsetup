# MIT License
#
# Copyright (c) 2020 Manish Sahani
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias g=git
alias vi=nvim
alias refresh='source "$HOME/.zshrc"'
alias reload='exec /opt/homebrew/bin/zsh -l'
alias path='print -l $path'
alias b=bat
alias cat=bat

c() {
  /usr/bin/tr -d '\n' | /usr/bin/pbcopy
}

ccd() {
  pwd -P | c
}

if (( $+commands[eza] )); then
  alias ls='eza -l --icons=auto'
  alias l='eza -l --icons=auto'
  alias la='eza -la --icons=auto'
  alias lsd='eza -l --only-dirs --icons=auto'
  alias lst='eza --tree --icons=auto'
else
  alias ls='/bin/ls -G'
  alias l='/bin/ls -lG'
  alias la='/bin/ls -laG'
fi

_resolve_fzf_colorscheme() {
  if [[ $TERM =~ "xterm-256color" ]]; then
    echo "--color fg:223,bg:-1,hl:66,fg+:166,bg+:-1,hl+:208
          --color info:183,prompt:110,spinner:107,pointer:167,marker:215,border:223"
  else
    echo "--color fg:#ebdbb2,bg:-1,hl:#458588,fg+:#d65d0e,bg+:-1,hl+:#fabd2f \
          --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54,border:#ebdbb2"
  fi
}

f() {
  fzf --height=90% \
    --preview 'bat --style=numbers --color=always --line-range :500 {}' \
    --preview-window right,border-left \
    --padding=0 \
    "$@"
}

v() {
  local selected
  selected="$(f "$@")" || return 0
  [[ -n "$selected" ]] || return 0
  nvim -- "$selected"
}

mkd() {
  if (( $# != 1 )); then
    printf '%s\n' 'usage: mkd <directory>' >&2
    return 64
  fi

  mkdir -p -- "$1" && cd -- "$1"
}

o() {
  if (( $# == 0 )); then
    /usr/bin/open .
  else
    /usr/bin/open "$@"
  fi
}
