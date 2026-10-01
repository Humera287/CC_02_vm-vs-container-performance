#!/bin/bash

sudo apt update
sudo apt upgrade -y

sudo apt install -y \
    sysbench \
    fio \
    iperf3 \
    htop \
    sysstat \
    python3 \
    python3-pip \
    git

echo "Checking installed tools..."

sysbench --version
fio --version
iperf3 --version
python3 --version
git --version

echo "Checking VM resources..."

nproc
free -h
lsblk
df -h
uname -a

echo "VM setup completed successfully."
