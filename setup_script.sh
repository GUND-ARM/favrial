#!/bin/sh

#
# 使い方:
#   ssh favrial-staging 'cat > /tmp/s && chmod +x /tmp/s && /tmp/s' < setup.sh favrial-staging staging.favrial.sulemio.jp
#

set -eu

hostname="${1}"
fqdn="${2}"
email="${3}"

echo "HELLO, ${hostname} for ${fqdn}"

# ユーザに確認を求める
printf "ドメインの設定は完了していますか？[y/N] "
read -r answer
if [ "${answer}" != "y" ]; then
    echo "先にドメインの設定を行ってください."
    exit 1
fi

# ホスト名を設定
cat <<EOF > /etc/cloud/cloud.cfg.d/99_hostname.cfg
#cloud-config
hostname: ${hostname}
fqdn: ${fqdn}
EOF

# パッケージを更新
apt-get update -y

# docker をインストール
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
mkdir -m 0755 -p /etc/apt/keyrings
rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker debian

# nginx をインストール
apt-get install -y nginx

# certbot をインストール
apt-get install -y certbot python3-certbot-nginx
cp /tmp/nginx.conf /etc/nginx/sites-available/default

# certbot を実行
certbot --nginx -d "${fqdn}" --agree-tos -m "${email}"

# 証明書をrenewするためのcronを設定
echo "0 0 1 * * /usr/bin/certbot renew --quiet" > /tmp/crontab
crontab /tmp/crontab
