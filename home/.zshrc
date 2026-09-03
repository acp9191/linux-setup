# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"


# PATH
export PATH="$HOME/.local/bin:$PATH"


# Git aliases
alias gco="git checkout"
alias gcm="git commit -m"
alias gaa="git add ."
alias gpl="git pull"
alias gps="git push"
alias gbr="git branch"
alias gbd="git branch -d"
alias gcl="git clone"
alias gd="git diff"
alias gds="git diff --staged"
alias gs="git status"


# GPG
export GPG_TTY=$(tty)
