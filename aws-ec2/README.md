# installing basic inference

Specifications:

- EC2 `g5.xlarge` instance, `g5.2xlarge` for production
- EC2 NVMe volume of 250GiB (hf_models)
- EBS `gp3` volume of 64GiB (root)
- NVIDIA a10g 24GB GPU, Compute rev. 8.6, CUDA 12.x compatible
- Ubuntu Linux 22.04-server

## Manual installation.

The Terraform should set all this up for you, but if you wanted to implement this manually:

Run directly as a `root` user.

```bash
export APP_HOME="/opt/inference"
echo "APP_HOME=${APP_HOME}" | tee -a /etc/environment
mkdir -p "${APP_HOME}/data" "${APP_HOME}/repos" "${APP_HOME}/s3"
# Example setup for Ubuntu Server 24.04 AMI
add-apt-repository -y universe multiverse restricted -s -p backports
apt-get update
apt upgrade -y
apt install -y \
    wget curl htop net-tools \
    lolcat figlet fortune-mod cowsay neofetch \
    build-essential ca-certificates ubuntu-drivers-common pkg-config \
    zlib1g-dev libncurses-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev liblzma-dev \
    git git-lfs unzip zip \
    python3-pip python3-venv python3-wheel python-is-python3
# Install awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
bash ./aws/install
# Setup NVIDIA hardware
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
apt update
ubuntu-drivers install --gpgpu
apt install -y nvidia-dkms-550-server nvidia-fabricmanager-550 libnvidia-nscq-550 nvidia-utils-550-server nvtop nvidia-cuda-toolkit
# Kernel options
echo "vm.swappiness=10" | tee -a /etc/sysctl.conf
sysctl vm.swappiness=10
# Set the hostname
export AWS_DEFAULT_REGION="ca-central-1"
export instance_id=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep instanceId | awk -F "\"" {' print $4 '})
export my_hostname=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" "Name=key,Values=Name" --query "Tags[0].Value" --output text)
hostnamectl set-hostname $my_hostname
hostnamectl set-hostname $my_hostname --pretty
```

## Setup Python environment manager

Run as your worker or service user.

```bash
# properly manage python environments
pip install --upgrade pip
curl https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
source ${HOME}/.bashrc
pyenv update
pyenv install 3.11
pyenv global 3.11
python --version
```

## Configure Ephemeral storage

Run as your worker or service user. Ensure that you have `sudo` access.

```bash
#!/bin/bash
export SWAP_SIZE="62.1G"
## Mount the data storage directory
sudo file -s /dev/nvme1n1
sudo mkfs -t xfs /dev/nvme1n1
sudo mount /dev/nvme1n1 ${APP_HOME}/data
# Default user ownership
sudo chown ubuntu:ubuntu ${APP_HOME}/data
# Swapfile equivalent of RAM on data nvme
sudo rm -rf ${APP_HOME}/data/swapfile
sudo fallocate -l ${SWAP_SIZE} ${APP_HOME}/data/swapfile
sudo chmod 600 ${APP_HOME}/data/swapfile
sudo mkswap ${APP_HOME}/data/swapfile
sudo swapon ${APP_HOME}/data/swapfile
# HuggingFaceHub cache on data disk
mkdir -p ${APP_HOME}/data/huggingface
ln -s ${APP_HOME}/data/huggingface ${HOME}/.cache/huggingface
```
