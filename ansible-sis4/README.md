# SIS4: Ansible automation of the IT Excuse Generator stack

One command builds the whole base of the project from SIS 1-3 on two Ubuntu VMs.

    VM1 (frontend): Nginx, web page, proxy /api/ -> VM2
    VM2 (backend):  Python API (systemd), Redis, users and permissions

## Files

| File | What it is |
|---|---|
| inventory.ini | The only place with IP addresses (vm1, vm2) |
| group_vars/all.yml | Variables: users, folders, port, excuses |
| playbook.yml | 3 plays (all, backend, frontend) + 19 smoke tests |
| templates/ | Nginx config, systemd unit, API application (use variables) |
| files/index.html | Web page with the "Generate Excuse" button |
| ansible.cfg | Ansible settings |
| setup.sh | Prepares VM1 (Ansible, SSH key, sudo) and runs the playbook |

## What is automated from SIS 1-3

| SIS | Task | Where in playbook |
|---|---|---|
| 1 | Folders /var/www, /opt/excuse-api, /var/log | file tasks |
| 1 | Nginx page + request to the backend | Nginx config template, proxy_pass |
| 1 | Python API + Redis database | main.py template, redis-server, SADD |
| 1 | Auto-restart | systemd unit, Restart=always |
| 2 | Groups and users (deploy-bot, develop-team, redis) | group, user |
| 2 | Limited sudo for deploy-bot | /etc/sudoers.d/deploy-bot |
| 2 | Permissions (chmod 700 backups, SSH folder) | file tasks |
| 2 | SSH access for deploy-bot | .ssh, authorized_keys |
| 2 | systemd unit | excuse-api.service |
| 3 | Packages (Nginx, Git from PPA, pip requests) | apt, pip |
| 3 | Time problem and apt lock | timedatectl set-ntp, apt lock_timeout |
| 3 | Firewall UFW (22, 80, 8000) | ufw tasks |
| 3 | test.sh checks | SMOKE TESTS 1-19 |

Not done by Ansible: creating the VMs in VirtualBox and the bridged network.

## Run

    git clone https://github.com/MariyaOvcharova/LDOS.git
    cd LDOS/ansible-sis4
    bash setup.sh

Next runs: `ansible-playbook playbook.yml`

If the network changes, edit only the IP addresses in inventory.ini.
