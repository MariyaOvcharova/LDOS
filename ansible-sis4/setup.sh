#!/bin/bash

BACKEND=$(awk '/^vm2/ {print $2}' inventory.ini | cut -d= -f2)
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER
sudo chmod 440 /etc/sudoers.d/$USER
sudo apt update
sudo apt install -y ansible git
echo n | ssh-keygen -q -t ed25519 -N "" -f ~/.ssh/id_ed25519
ssh-copy-id mariya@$BACKEND
ssh -t mariya@$BACKEND "echo 'mariya ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/mariya; sudo chmod 440 /etc/sudoers.d/mariya"
ansible-playbook playbook.yml
