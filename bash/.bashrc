## Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Shell options
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
# append to the history file, don't overwrite it
shopt -s histappend
# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000



# Thanks for the color fix here Tad Hetke :^)
TH_OPEN="\["
TH_CLOSE="\]"
TH_NORM_30="${TH_OPEN}\e[0;30m${TH_CLOSE}" # black
TH_NORM_31="${TH_OPEN}\e[0;31m${TH_CLOSE}" # red
TH_NORM_32="${TH_OPEN}\e[0;32m${TH_CLOSE}" # green
TH_NORM_33="${TH_OPEN}\e[0;33m${TH_CLOSE}" # brown
TH_NORM_34="${TH_OPEN}\e[0;34m${TH_CLOSE}" # blue
TH_NORM_35="${TH_OPEN}\e[0;35m${TH_CLOSE}" # purple
TH_NORM_36="${TH_OPEN}\e[0;36m${TH_CLOSE}" # cyan
TH_NORM_37="${TH_OPEN}\e[0;37m${TH_CLOSE}" # gray
TH_BOLD_30="${TH_OPEN}\e[1;30m${TH_CLOSE}" # bold black
TH_BOLD_31="${TH_OPEN}\e[1;31m${TH_CLOSE}" # bold red
TH_BOLD_32="${TH_OPEN}\e[1;32m${TH_CLOSE}" # bold green
TH_BOLD_33="${TH_OPEN}\e[1;33m${TH_CLOSE}" # bold brown
TH_BOLD_34="${TH_OPEN}\e[1;34m${TH_CLOSE}" # bold blue
TH_BOLD_35="${TH_OPEN}\e[1;35m${TH_CLOSE}" # bold purple
TH_BOLD_36="${TH_OPEN}\e[1;36m${TH_CLOSE}" # bold cyan
TH_BOLD_37="${TH_OPEN}\e[1;37m${TH_CLOSE}" # bold gray
TH_CLOSE_COLOR="${TH_OPEN}\e[m${TH_CLOSE}"
PS1="${TH_BOLD_34}\w${TH_CLOSE_COLOR}\n${TH_NORM_32}\u${TH_CLOSE_COLOR}@${TH_NORM_32}\h${TH_CLOSE_COLOR} > "

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# user stuff
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/lib:$PATH"
export PATH="$HOME/tools:$PATH"

## vi motions in cli
set -o vi

## venv
show_virtual_env() {
  if [ -n "$VIRTUAL_ENV" ]; then
    echo "($(basename $VIRTUAL_ENV))"
  fi
}
PS1='$(show_virtual_env)'$PS1

## source aliases
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

## inputrc
if [ -e $HOME/.inputrc ]; then
    source $HOME/.inputrc
fi

### node ####################################################
export PATH="/home/abram/tools/node/v25.7.0/bin:$PATH"
### neovim ##################################################
export PATH="/home/abram/tools/nvim/v0.12.0-dev-2459+g62135f5a57/bin:$PATH"
### fzf (junegun) ###########################################
export PATH="/home/abram/tools/fzf/v0.68.0/bin:$PATH"
source "/home/abram/tools/fzf/v0.68.0/shell/completion.bash"
source "/home/abram/tools/fzf/v0.68.0/shell/key-bindings.bash"

