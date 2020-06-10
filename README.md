# dangerscripts
My Linux configuration files.

## Installing
Clone this repo to your home directory:
    git clone https://github.com/jordan-yee/dangerscripts.git ~/dangerscripts

Before attempting to install packages with apt-get, update package lists
with the command:
    sudo apt update

### zshell
Ubuntu 20.04:
1. Install zsh
   `sudo apt install zsh`
2. Make zsh the default shell
   `chsh`
3. Use the dangerscripts config
   `cp ~/dangerscripts/.zshrc ~/.zshrc`

### tmux
Ubuntu 20.04:
1. tmux is pre-installed on Ubuntu 20.04
   To update run:
   `sudo apt install tmux`
2. Use the dangerscripts config
   `cp ~/dangerscripts/.tmux.conf ~/.tmux.conf`
