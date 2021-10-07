#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

set -e
set -x
export DEBIAN_FRONTEND=noninteractive

# Stop jenkins if running
systemctl stop jenkins

# Generate certificate
certbot --nginx --domain ${domain_name} --non-interactive --agree-tos --email admin@${domain_name}

# Activate website (patch nginx config with domain first)
systemctl stop nginx
rm -f /etc/nginx/sites-enabled/default
sed -i.bak 's/__DOMAIN__/${domain_name}/g' /etc/nginx/sites-available/jenkins
ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
systemctl restart nginx

# Configure custom backups
apt-get install -y -q cron
pip install jenkins-backup-s3
backup-jenkins --bucket=${backup_bucket} create
crontab -l | { cat; echo "0 0 0 0 0 backup-jenkins --bucket=${backup_bucket} create"; } | crontab -

# Finally, start Jenkins
systemctl restart jenkins
