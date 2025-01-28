#!/bin/bash

# Hacer que el script se detenga si ocurre un error
set -e

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar paquetes comunes
echo "Instalando paquetes comunes..."
sudo apt install -y curl wget git vim build-essential

# Instalar Docker
echo "Instalando Docker..."
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Instalar Node.js y npm
echo "Instalando Node.js y npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Limpiar paquetes innecesarios
echo "Limpiando paquetes innecesarios..."
sudo apt autoremove -y
sudo apt autoclean -y

# Finalizar
echo "El script se ejecutó correctamente. ¡Todo listo!"
