# .dotfiles

## Dependencies
Linux
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install stow
sudo apt-get install ripgrep ## nvim treesitter
sudo apt install pkg-config libevent-dev libncurses-dev build-essential bison ## tmux
```

## Usage
To load dotfiles for bash
```
cd .dotfiles/
stow bash ## creates symlinks like ~/.bashrc -> <path_to_dotfiles>/.dotfiles/bash/.bashrc
```
