#!/bin/bash

# Check and Install Fliget and Toilet in case it is not present
if ! command -v figlet &> /dev/null; then
    echo "Instalando figlet..."
    sudo apt-get update && sudo apt-get install -y figlet
fi

if ! command -v toilet &> /dev/null; then
    echo "Instalando toilet..."
    sudo apt-get install -y toilet
fi

# Show Banner
clear
echo "=========================================="
figlet -c "LabScale"
echo "=========================================="
echo "Este script foi desenvolvido pelo time da LabScale."
echo "Acesse nosso site: https://dashboard.labscale.com.br"
echo "=========================================="

sleep 2

# Check root user
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script precisa ser executado como root!"
    exit 1
fi

# get the network id
read -p "Digite o ZeroTier Network ID: " NETWORK_ID

# Check if the zero-tier is installed, if not will install
if ! command -v zerotier-cli &> /dev/null; then
    echo "ZeroTier não encontrado. Instalando..."
    curl -s https://install.zerotier.com | sudo bash
else
    echo "ZeroTier já está instalado."
fi

# ensure zero-tier is running
sudo systemctl enable zerotier-one
sudo systemctl start zerotier-one

# Join Zero-Tier Network
echo "Ingressando na rede $NETWORK_ID..."
sudo zerotier-cli join "$NETWORK_ID"

echo "Join solicitado! Autorize o dispositivo no painel do ZeroTier."
echo "Para verificar o status da conexão, use: sudo zerotier-cli listnetworks"


# Path to Netplan
NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"

echo "Configurando a interface eth1 com IP 192.168.0.1/30..."
cat <<EOF > $NETPLAN_FILE
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
    eth1:
      addresses:
        - 192.168.0.1/30
      routes:
        - to: 100.64.0.0/16
          via: 192.168.0.2
EOF

echo "Aplicando as configurações de rede..."
sudo netplan apply

# Enable Kernel Routing
echo "Habilitando roteamento no kernel..."
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-zerotier.conf > /dev/null
sudo sysctl -p /etc/sysctl.d/99-zerotier.conf

echo "Configuração concluída com sucesso!"

