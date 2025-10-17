#!/bin/bash

echo "[+] Sincronizando memoria y limpiando cachés..."
sync
echo 3 > /proc/sys/vm/drop_caches

echo "[+] Desactivando swap existente..."
swapoff -a

echo "[+] Creando nuevo swapfile de 2G..."
fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048

chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

echo "[+] Haciendo persistente el swap en /etc/fstab..."
grep -q "/swapfile" /etc/fstab || echo "/swapfile none swap sw 0 0" >> /etc/fstab

echo "[+] Ajustando vm.overcommit_memory=1 y swappiness=10..."
sysctl -w vm.overcommit_memory=1
sysctl -w vm.swappiness=10

echo 'vm.overcommit_memory=1' >> /etc/sysctl.conf
echo 'vm.swappiness=10' >> /etc/sysctl.conf

echo "[+] Permisos del directorio"
sudo chown redis:redis /var/lib/redis
sudo chmod 770 /var/lib/redis

echo "[✓] Configuración completa. Se recomienda reiniciar el sistema."
