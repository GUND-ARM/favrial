#!/bin/sh
#
# 使い方::
#   ./setup_host.sh <ホスト名> <FQDN>
#
# 例:
#   ./setup_host.sh favrial-staging staging.favrial.sulemio.jp miorine@sulemio.jp
#

set -eu

hostname="${1}"
fqdn="${2}"
email="${3}"

ssh "${hostname}" 'cat > /tmp/s && chmod +x /tmp/s' < setup_script.sh
sed "s/\${DOMAIN_NAME}/${fqdn}/g" < nginx.conf.template |
  ssh "${hostname}" 'cat > /tmp/nginx.conf'
ssh "${hostname}" 'sudo /tmp/s' "${hostname}" "${fqdn}" "${email}"
ssh "${hostname}" 'rm /tmp/s && rm /tmp/nginx.conf && sudo reboot'
