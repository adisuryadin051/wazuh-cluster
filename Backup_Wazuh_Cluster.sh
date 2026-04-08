
#!/bin/bash

# ==========================================================
# KONFIGURASI (Ubah NODE_NAME sesuai server yang dipakai)
# ==========================================================
NODE_NAME="server-1"  # Ganti jadi server-2, server-3 di server lain
REPO_URL="https://github.com/adisuryadin051/wazuh-cluster.git"
BACKUP_DIR="/root/wazuh-cluster"

GIT_NAME="Adi Suryadin"
GIT_EMAIL="adisuryadin051@email.com"

echo "=== Memulai Backup Wazuh Cluster: $NODE_NAME ==="

# 1. Siapkan Struktur Folder
mkdir -p $BACKUP_DIR/$NODE_NAME/manager/rules
mkdir -p $BACKUP_DIR/$NODE_NAME/indexer
mkdir -p $BACKUP_DIR/$NODE_NAME/dashboard

# 2. Ambil File Konfigurasi (Sesuaikan path jika berbeda)
cp /var/ossec/etc/ossec.conf $BACKUP_DIR/$NODE_NAME/manager/ 2>/dev/null
cp -r /var/ossec/etc/rules/* $BACKUP_DIR/$NODE_NAME/manager/rules/ 2>/dev/null
cp /etc/wazuh-indexer/opensearch.yml $BACKUP_DIR/$NODE_NAME/indexer/ 2>/dev/null
cp /etc/wazuh-dashboard/opensearch_dashboards.yml $BACKUP_DIR/$NODE_NAME/dashboard/ 2>/dev/null

# 3. Sinkronisasi dengan GitHub
cd $BACKUP_DIR || exit

# Set Identitas Git
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Inisialisasi jika belum ada
if [ ! -d ".git" ]; then
    git init
    git branch -M main
    git remote add origin $REPO_URL
fi

# Tarik data terbaru dari GitHub (PENTING agar tidak rejected)
echo "[*] Sinkronisasi data dari GitHub..."
git pull origin main --allow-unrelated-histories --no-rebase > /dev/null 2>&1

# Tambah, Commit, dan Push
git add .
if git commit -m "Auto-backup Wazuh $NODE_NAME pada $(date +'%Y-%m-%d %H:%M:%S')"; then
    echo "[*] Mengirim perubahan ke GitHub..."
    git push origin main
else
    echo "[!] Tidak ada perubahan data. Skip push."
fi

echo "=== Selesai Backup Wazuh ==="
