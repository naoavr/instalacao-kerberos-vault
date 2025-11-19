#!/bin/bash

set -e

echo "Atualizando sistema..."
apt update && apt upgrade -y

echo "Instalando dependências básicas..."
apt install -y ca-certificates curl gnupg lsb-release software-properties-common

echo "Configurando repositório Docker oficial..."

# Limpar chave antiga se existir
rm -f /etc/apt/keyrings/docker.gpg

mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Atualizando lista de pacotes..."
apt update

echo "Instalando Docker..."
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "Configurando grupo docker..."
if ! getent group docker > /dev/null; then
  groupadd docker
fi

usermod -aG docker $USER

echo "Iniciando e ativando serviço docker..."
systemctl enable --now docker

echo "Puxando imagem do Kerberos.io Vault..."
docker pull kerberos/kerberos

echo "Iniciando container Kerberos Vault..."
docker run --name kerberos-vault -p 80:80 -p 8889:8889 -d kerberos/kerberos

echo "Instalação completa. Faça logout/login para aplicar permissões do grupo docker."
