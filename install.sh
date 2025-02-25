#!/bin/bash

# Verifica se o usuário é root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script precisa ser executado como root!"
    exit 1
fi

# Solicita o Network ID ao usuário
read -p "Digite o ZeroTier Network ID: " NETWORK_ID

# Verifica se o ZeroTier já está instalado, se não estiver, instala
if ! command -v zerotier-cli &> /dev/null; then
    echo "ZeroTier não encontrado. Instalando..."
    curl -s https://install.zerotier.com | sudo bash
else
    echo "ZeroTier já está instalado."
fi

# Garante que o serviço do ZeroTier está rodando
sudo systemctl enable zerotier-one
sudo systemctl start zerotier-one

# Faz o join na rede informada pelo usuário
echo "Ingressando na rede $NETWORK_ID..."
sudo zerotier-cli join "$NETWORK_ID"

echo "Join solicitado! Autorize o dispositivo no painel do ZeroTier."
echo "Para verificar o status da conexão, use: sudo zerotier-cli listnetworks"


# Caminho do arquivo Netplan
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

echo "Configuração concluída com sucesso!"

