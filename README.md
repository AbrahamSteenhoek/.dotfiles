# .dotfiles

## Dependencies
Linux
```
sudo apt-get install stow
sudo apt-get install ripgrep ## nvim treesitter
```

## Usage
To load dotfiles for bash
```
cd .dotfiles/
stow bash ## creates symlinks like ~/.bashrc -> <path_to_dotfiles>/.dotfiles/bash/.bashrc
```
