#!/bin/bash

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
