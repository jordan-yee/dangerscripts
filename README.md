# dangerscripts
This repo contains various Linux configuration files.

## Organization
Each application has its own directory containing all config files relevant
to that application.

The backup and restore scripts are being phased out, since most config files
will have to be reviewed and modified to some extent for each system they're
used on.

# [Deprecated]
All instructions below are to be phased out.

## Installing
Clone this repo to your home directory:
    git clone https://github.com/jordan-yee/dangerscripts.git ~/dangerscripts

To quickly backup changes to your configs, create a link to the backup script in
your ~/bin directory:
		ln ~/dangerscripts/backup-configs.sh ~/bin/backup-configs.sh

Then after making changes to a config file, you can run:
    backup-configs.sh

### zshell
To update this repo's saved config:
  `cp -u ~/.zshrc ~/dangerscripts/.zshrc`

Ubuntu 20.04:
1. Install zsh
   `sudo apt install zsh`
2. Make zsh the default shell
   `chsh`
3. Review the dependecies listed in this repo's `.zshrc`, and
   install any necessary system utilities accordingly.
3. Use the dangerscripts config
   `cp ~/dangerscripts/.zshrc ~/.zshrc`

### tmux
To update this repo's saved config:
  `cp -u ~/.tmux.conf ~/dangerscripts/.tmux.conf`

Ubuntu 20.04:
1. tmux is pre-installed on Ubuntu 20.04
   To update run:
   `sudo apt install tmux`
2. Use the dangerscripts config
   `cp ~/dangerscripts/.tmux.conf ~/.tmux.conf`

### Kakoune
To update this repo's saved config:
  `cp -u ~/.config/kak/kakrc ~/dangerscripts/kakrc`

Ubuntu 20.04:
1. Install dependencies:
   `sudo apt install build-essential pkg-config libncurses5-dev libncursesw5-dev`
   NOTE: build-essential should include g++, gcc, and make, but this is untested, as I've only tested installing build-essential after gcc and make were already installed.
2. Download Kakoune binaries:
   `git clone https://github.com/mawww/kakoune.git`
3. Install Kakoune:
   From the 'src' directory of the repository run:
   ```
   make
   sudo make install
   ```
4. User the dangerscripts config
   `mkdir -P ~/.config/kak && cp ~/dangerscripts/kakrc ~/.config/kak/kakrc`
5. Install the plugin manager used in kakrc
   ```
   mkdir -p ~/.config/kak/plugins/
   git clone https://github.com/andreyorst/plug.kak.git ~/.config/kak/plugins/plug.kak
   ```
6. Install plugins configured in kakrc
   First, open kak, then run the command:
   `:plug-install`
