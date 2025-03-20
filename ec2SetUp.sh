#!/bin/bash
sudo systemctl enable webappFlask
sudo systemctl start webappFlask.service
sudo apt install mysql-client -y

