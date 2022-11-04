#!/bin/bash

DOTFILES_PATH="$HOME/.config/dotfiles"

# Install the important stuff first
#apt-get update
#apt-get install -y git vim gpg wget

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
[[ ! -f $HOME/.ssh/id_rsa_dotfiles.gpg ]] && wget https://github.com/frankdice/dotfiles/raw/main/id_rsa.gpg -O $HOME/.ssh/id_rsa_dotfiles.gpg

# Decrypt the private key - User Interaction
[[ ! -f $HOME/.ssh/id_rsa_dotfiles  ]] && gpg --output $HOME/.ssh/id_rsa_dotfiles --decrypt $HOME/.ssh/id_rsa_dotfiles.gpg

# .ssh permissions for dotfiles
if ! [[ $(stat -c "%A" ~/.ssh/id_rsa_dotfiles) == "-rw-------" ]]
then
    chmod 600 $HOME/.ssh/id_rsa_dotfiles*
fi

# git clone my bootstrap repo
[[ ! -d "$HOME/.config/" ]] && mkdir -p $HOME/.config

if [[ ! -d $DOTFILES_PATH ]] 
then
    GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_rsa_dotfiles" git clone git@github.com:frankdice/dotfiles.git $DOTFILES_PATH
else
#    cd $HOME/.config/dotfiles
#    git pull
    echo "Updating existing dotfiles repo"
fi

# local symlinks
symlinks "$HOME/.gitconfig" "dot/gitconfig"
symlinks "$HOME/bin" "bin"
