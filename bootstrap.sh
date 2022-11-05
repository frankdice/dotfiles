#!/bin/bash

SETTINGS_FILE=$HOME/.config/dotfiles/settings

if [ -f $SETTINGS_FILE ];then
    . $SETTINGS_FILE
else
    DOTFILES_PATH="$HOME/.config/dotfiles"
    DOTFILES_SSH_KEY="$HOME/.ssh/id_rsa_dotfiles"
fi


# Install the important stuff first
apt-get update
apt-get install -y git vim gpg wget fzf # 

symlinks () {
    [[ ! -L "$1" &&  -d "$1" ]] && echo "$1 folder already exists. Please move and re-bootstrap" && return
    if [[ $(readlink $1) != "$DOTFILES_PATH/$2" ]]
    then
        if [[ -f $1 ]]
	then
	    echo "Moving $1 to $1.bak"
	    mv $1 $1.bak
	fi

	ln -fs $DOTFILES_PATH/$2 $1 
    fi

}

# ssh folder and decrypting


# Make and permission .ssh folder
if [ ! -d "$HOME/.ssh" ]
then
    mkdir $HOME/.ssh
    chmod 700 $HOME/.ssh
fi

# If encrypted key doesn't exist, download it
[[ ! -f $DOTFILES_SSH_KEY.gpg ]] && wget https://github.com/frankdice/dotfiles/raw/main/id_rsa.gpg -O $DOTFILES_SSH_KEY.gpg

# Decrypt the private key - User Interaction
[[ ! -f $DOTFILES_SSH_KEY  ]] && gpg --output $DOTFILES_SSH_KEY --decrypt $DOTFILES_SSH_KEY.gpg

# .ssh permissions for dotfiles
if ! [[ $(stat -c "%A" $DOTFILES_SSH_KEY) == "-rw-------" ]]
then
    chmod 600 $DOTFILES_SSH_KEY*
fi

# git clone my bootstrap repo
[[ ! -d "$HOME/.config/" ]] && mkdir -p $HOME/.config

if [[ ! -d $DOTFILES_PATH ]] 
then
    GIT_SSH_COMMAND="ssh -i $DOTFILES_SSH_KEY" git clone git@github.com:frankdice/dotfiles.git $DOTFILES_PATH
fi

$DOTFILES_PATH/bin/dotfiles setup

# local symlinks
#symlinks "$HOME/bin" "bin"
#symlinks "$HOME/.gitconfig" "dot/gitconfig"
#symlinks "$HOME/.bash_aliases" "dot/bash_aliases"
