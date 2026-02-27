# some more ls aliases
alias ls='ls --color=auto'
alias ll='ls -lF'
alias lla='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias v='nvim'
alias view='nvim -R'

alias browse='$BROWSER'

# dotfiles
alias config='$(which git) --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias gs='git status'
alias ga='git add'
