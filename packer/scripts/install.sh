#!/bin/bash
set -x
set -e
export DEBIAN_FRONTEND=noninteractive

# Update all packages
function update_system() {
  apt-get update
  apt-get upgrade -y -q
  apt-get install -y -q apt-transport-https jq unattended-upgrades
  apt-get install -y -q python3-pip
  pip install awscli
}

# Set Hostname, Timezone
function set_hostname_timezone() {
  echo "Set Hostname"
  hostnamectl set-hostname --static "${domain}"
  export HOSTNAME="${domain}"

  echo "Set Timezone"
  timedatectl set-timezone UTC
}

function create_awscli_conf() {
  echo "Creating awscli.conf for CloudWatch Agent"
  mkdir -p /etc/awslogs
  cat << 'EOF' > /etc/awslogs/awscli.conf
[plugins]
cwlogs = cwlogs
[default]
region = ${aws_region}
EOF
}

function create_awslogs_conf() {
  mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
  cat << 'EOF' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "metrics_collection_interval": 30,
    "logfile": "/var/log/amazon-cloudwatch-agent.log",
    "debug": true
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/user-data.log"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/cloud-init-output.log"
          },
          {
            "file_path": "/var/log/cloud-init.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/cloud-init.log"
          },
          {
            "file_path": "/var/log/auth.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/auth.log"
          },
          {
            "file_path": "/var/log/boot.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/boot.log"
          },
          {
            "file_path": "/var/log/dpkg.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/dpkg.log"
          },
          {
            "file_path": "/var/log/kern.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/kern.log"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/nginx/error.log"
          },
          {
            "file_path": "/var/log/letsencrypt/letsencrypt.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/letsencrypt/letsencrypt.log"
          },
          {
            "file_path": "/var/log/jenkins-backup.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/jenkins-backup.log"
          }
        ]
      }
    }
  }
}
EOF
}

function install_cloudwatch_agent() {
  echo "Install CloudWatch Agent"
  wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
  dpkg -i amazon-cloudwatch-agent.deb
  echo "Enable CloudWatch Agent at boot via systemd"
  systemctl enable amazon-cloudwatch-agent
}

function install_configure_nginx {
  apt-get install -y -q nginx
  cp /tmp/scripts/jenkins.site-available /etc/nginx/sites-available/jenkins
}

function install_letsencrypt() {
  # https://certbot.eff.org/lets-encrypt/ubuntufocal-nginx
  snap install core
  snap refresh core
  apt-get remove certbot
  snap install --classic certbot
  ln -s /snap/bin/certbot /usr/bin/certbot
  # Certificate will be claimed at startup, in user-data
}

function install_configure_jenkins() {
  apt-get install -y -q  default-jre
  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
  sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
  apt-get update
  apt-get install -y -q jenkins
  cp /tmp/scripts/jenkins.default /etc/default/jenkins
}

function restart_services() {
  # Restart services
  systemctl restart amazon-cloudwatch-agent
  systemctl restart nginx
}

# START
update_system
set_hostname_timezone
sleep 5
create_awscli_conf
create_awslogs_conf
install_cloudwatch_agent
install_configure_nginx
restart_services
install_letsencrypt
restart_services
install_configure_jenkins
restart_services
# END
