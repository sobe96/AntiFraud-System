#!/bin/bash
LOG_FILE="provision.log"
MASTER_IP=""
ACCESS_KEY=""
SECRET_KEY=""
S3_BUCKET=""
TOKEN=""
CLOUD_ID=""
FOLDER_ID=""
PRIVATE_KEY=""
UPLOAD_DATA_TO_HDFS_CONTENT=""

while [[ $# -gt -0 ]] ; do
  key="$1"
  case $key in
    --master_ip)
      MASTER_IP="$2"
      shift
      shift
      ;;
    --access_key)
      ACCESS_KEY="$2"
      shift
      shift
      ;;
    --secret_key)
      SECRET_KEY="$2"
      shift
      shift
      ;;
    --s3_bucket)
      S3_BUCKET="$2"
      shift
      shift
      ;;
    --token)
      TOKEN="$2"
      shift
      shift
      ;;
    --cloud_id)
      CLOUD_ID="$2"
      shift
      shift
      ;;
    --folder_id)
      FOLDER_ID="$2"
      shift
      shift
      ;;
    --private_key_path)
      PRIVATE_KEY="$2"
      shift
      shift
      ;;
    --upload_data_to_hdfs_content)
      UPLOAD_DATA_TO_HDFS_CONTENT="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$MASTER_IP" || -z "$ACCESS_KEY" || -z "$SECRET_KEY" || -z "$S3_BUCKET" || -z "$TOKEN" || -z "$CLOUD_ID" || -z "$FOLDER_ID" || -z "$PRIVATE_KEY" || -z "$UPLOAD_DATA_TO_HDFS_CONTENT" ]]; then
  echo "Missing required arguments."
  exit 1
fi
# Функция для логирования
function log() {
    sep="----------------------------------------------------------"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $sep " | tee -a $LOG_FILE
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $1" | tee -a $LOG_FILE
}

log "Starting user data script execution"

log "echo 'Master IP: $MASTER_IP"
log "echo 'Bucket Name: $S3_BUCKET"
log "echo 'Private Key: $PRIVATE_KEY"

log "Connecting to Master node..."
ssh -o StrictHostKeyChecking=no -i $PRIVATE_KEY ubuntu@$MASTER_IP <<EOF  | tee -a $LOG_FILE
echo 'Installing yc CLI'
export HOME='/home/ubuntu'
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

echo 'Changing ownership of yandex-cloud directory'
sudo chown -R ubuntu:ubuntu /home/ubuntu/yandex-cloud
sudo chown -R ubuntu:ubuntu /home/ubuntu/.config

echo 'Applying changes from .bashrc'
source /home/ubuntu/.bashrc

if command -v yc &> /dev/null; then
    echo 'yc CLI is now available'
    yc --version
else
    echo 'yc CLI is still not available. Adding it to PATH manually'
    export PATH='$PATH:/home/ubuntu/yandex-cloud/bin'
    yc --version
fi

echo 'Configuring yc CLI'
yc config set token ${TOKEN}
yc config set cloud-id ${CLOUD_ID}
yc config set folder-id ${FOLDER_ID}

echo 'Installing additional tools'
sudo apt-get update
sudo apt-get install -y tmux htop iotop

echo 'Installing s3cmd'
sudo apt-get install -y s3cmd

echo 'Configuring s3cmd'
cat <<EON > /home/ubuntu/.s3cfg
[default]
access_key = ${ACCESS_KEY}
secret_key = ${SECRET_KEY}
host_base = storage.yandexcloud.net
host_bucket = %(bucket)s.storage.yandexcloud.net
use_https = True
EON
cat /home/ubuntu/.s3cfg

chown ubuntu:ubuntu /home/ubuntu/.s3cfg
chmod 600 /home/ubuntu/.s3cfg


echo 'Copying file from source bucket to destination bucket'
s3cmd sync \
    --config=/home/ubuntu/.s3cfg \
    --acl-public \
    s3://otus-mlops-source-data/ \
    s3://$S3_BUCKET/

if [ $? -eq 0 ]; then
    echo 'Files successfully copied to $S3_BUCKET'
    echo 'Listing contents of $S3_BUCKET'
    s3cmd ls --config=/home/ubuntu/.s3cfg s3://$S3_BUCKET/
else
    echo 'Error occurred while copying files to $S3_BUCKET'
fi

echo 'Creating scripts directory on master node'
mkdir -p /home/ubuntu/scripts

echo 'Copying upload_data_to_hdfs.sh script to master node'
echo '${UPLOAD_DATA_TO_HDFS_CONTENT}' > /home/ubuntu/scripts/upload_data_to_hdfs.sh
sed -i 's/{{ s3_bucket }}/'$S3_BUCKET'/g' /home/ubuntu/scripts/upload_data_to_hdfs.sh

echo 'Setting permissions for upload_data_to_hdfs.sh on master node'
chmod +x /home/ubuntu/scripts/upload_data_to_hdfs.sh

echo 'User data script execution completed'

EOF

if [ $? -eq 0 ]; then
  log "Provisioning completed successfully"
else
  log "Provisioning failed"
fi

