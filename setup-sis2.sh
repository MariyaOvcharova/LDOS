#!/bin/bash

# 1. Создание группы и пользователя
sudo groupadd develop-team
sudo useradd -m -s /bin/bash deploy-bot
sudo usermod -aG develop-team deploy-bot

# 2. Настройка защищенной папки SSH для автоматизации 
sudo mkdir -p /home/deploy-bot/.ssh
sudo touch /home/deploy-bot/.ssh/authorized_keys
sudo chmod 700 /home/deploy-bot/.ssh
sudo chmod 600 /home/deploy-bot/.ssh/authorized_keys
sudo chown -R deploy-bot:deploy-bot /home/deploy-bot/.ssh

# 3. Создание рабочей директории и файла бэкенд-приложения
sudo mkdir -p /opt/excuse-api/app
sudo chown -R mariya:mariya /opt/excuse-api

sudo bash -c 'cat > /opt/excuse-api/app/main.py <<EOF
import time
while True:
    print("Excuse API is running")
    time.sleep(60)
EOF'

sudo chown mariya:mariya /opt/excuse-api/app/main.py

# 4. Создание и регистрация службы systemd
sudo bash -c 'cat > /etc/systemd/system/excuse-api.service <<EOF
[Unit]
Description=IT Excuse Generator Backend API
After=network.target

[Service]
User=mariya
WorkingDirectory=/opt/excuse-api/app
ExecStart=/usr/bin/python3 main.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable excuse-api.service
sudo systemctl start excuse-api.service

# 5. Настройка ограниченного sudo для deploy-bot 
echo "deploy-bot ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart excuse-api.service" | sudo tee /etc/sudoers.d/deploy-bot
