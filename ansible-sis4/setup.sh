#!/bin/bash
# setup.sh - prepare VM1 (control node) and run the Ansible playbook for SIS4
# Run on VM1 inside the folder ansible-sis4:  bash setup.sh
set -e

BACKEND_IP="192.168.0.13"
BACKEND_USER="mariya"
cd "$(dirname "$0")"

echo "== 1. Allow sudo without a password on VM1 =="
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null
sudo chmod 440 /etc/sudoers.d/$USER

echo "== 2. Install Ansible =="
sudo apt update
sudo apt install -y ansible
ansible --version

echo "== 3. Create an SSH key (if it does not exist) =="
[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519

echo "== 4. Copy the SSH key to the backend VM (password is needed once) =="
ssh-copy-id ${BACKEND_USER}@${BACKEND_IP}

echo "== 5. Allow sudo without a password on the backend VM =="
ssh -t ${BACKEND_USER}@${BACKEND_IP} "echo '${BACKEND_USER} ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/${BACKEND_USER} > /dev/null && sudo chmod 440 /etc/sudoers.d/${BACKEND_USER}"

echo "== 6. Run the playbook (setup + smoke tests) =="
ansible-playbook -i inventory.ini playbook.yml
