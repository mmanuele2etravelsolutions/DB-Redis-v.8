# Redis - Swapfile y Configuración de Overcommit en Ubuntu

## 🧠 ¿Qué significa este log de Redis?

```
1:C 06 Aug 2025 13:18:26.370 # WARNING Memory overcommit must be enabled! Without it, a background save or replication may fail under low memory condition. Being disabled, it can also cause failures without low memory condition, see https://github.com/jemalloc/jemalloc/issues/1328. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
```

### ❗ Interpretación:

Redis está advirtiendo que el sistema no tiene activado el parámetro `vm.overcommit_memory=1`, lo cual puede provocar:

- Fallos al guardar en segundo plano (`bgsave`)
- Problemas en la replicación
- Fallos aleatorios incluso sin baja memoria

### 🔧 Solución rápida:

1. Aplicar el cambio en tiempo real:
```bash
sudo sysctl -w vm.overcommit_memory=1
```

2. Hacerlo permanente:
```bash
echo 'vm.overcommit_memory=1' | sudo tee -a /etc/sysctl.conf
```

3. Reiniciar el sistema o el servicio Redis (opcional pero recomendado).

### 🔗 Más información:
[https://github.com/jemalloc/jemalloc/issues/1328](https://github.com/jemalloc/jemalloc/issues/1328)

---

## 🧰 Cómo crear un Swapfile en Ubuntu

Si tu sistema no tiene suficiente RAM, un swapfile puede ayudar a evitar errores como el anterior.

### ✅ Pasos para crear un swapfile de 2 GB:

1. Verificá si ya existe un área de swap:
```bash
swapon --show
```

2. Crear un archivo de 2GB:
```bash
sudo fallocate -l 2G /swapfile
```
> Alternativa si `fallocate` no está disponible:
```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
```

3. Darle los permisos correctos:
```bash
sudo chmod 600 /swapfile
```

4. Formatearlo como swap:
```bash
sudo mkswap /swapfile
```

5. Activarlo:
```bash
sudo swapon /swapfile
```

6. Confirmar que está activo:
```bash
swapon --show
free -h
```

7. Hacerlo permanente agregándolo a `/etc/fstab`:
```bash
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

### ⚙️ Ajustar `swappiness` (opcional):

Esto define cuán agresivamente el sistema usará swap.

```bash
sudo sysctl vm.swappiness=10
```

Para hacerlo permanente:
```bash
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```

---

## 📜 Script para automatizar creación de swapfile y ajuste de memoria

```bash
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

echo "[✓] Configuración completa. Se recomienda reiniciar el sistema."
```

---

## 🧾 Licencia

Este README fue generado automáticamente para documentación interna. Redis es software libre bajo licencia BSD. Configuraciones aplicadas al sistema operativo Ubuntu.
