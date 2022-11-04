#!/bin/bash

# Install the important stuff first
#apt-get update
#apt-get install -y git vim gpg wget

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

if [[ ! -d "$HOME/.config/dotfiles" ]] 
then
    GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_rsa_dotfiles" git clone git@github.com:frankdice/dotfiles.git $HOME/.config/dotfiles
else
    cd $HOME/config/dotfiles
    git pull
    echo "Updating existing dotfiles repo"
fi

# local symlinks

