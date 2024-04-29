# installing basic inference

Specifications:

- EC2 `g5.xlarge` instance, `g5.2xlarge` for production
- EC2 NVMe volume of 250GiB (hf_models)
- EBS `gp3` volume of 64GiB (root)
- NVIDIA a10g 24GB GPU, Compute rev. 8.6, CUDA 12.x compatible
- Ubuntu Linux 22.04-server

Potential ec2 user_data script:

```bash
# Update system
sudo apt update
sudo add-apt-repository -y universe
sudo add-apt-repository -y multiverse
sudo add-apt-repository -y restricted
sudo apt update
sudo apt-get install -y \
build-essential ca-certificates ubuntu-drivers-common pkg-config \
zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev liblzma-dev \
git git-lfs wget unzip zip btop htop curl \
python3-full python3-pip python3-venv python3-wheel python-is-python3 \
# Setup NVIDIA hardware
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo ubuntu-drivers install --gpgpu nvidia:550-server
sudo apt install -y cuda-toolkit nvidia-dkms-550-server nvidia-fabricmanager-550 libnvidia-nscq-550 nvidia-utils-550-server nvtop
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl vm.swappiness=10
sudo reboot
```

## Setup Python environment manager

```bash
# Get python configured
pip install --upgrade pip
curl https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
source .bashrc
pyenv update
pyenv install 3.11
pyenv local 3.11
```

## Configure local filesystem

```bash
export APP_HOME=/opt/openbet/inference
echo "APP_HOME=\"/opt/openbet/inference\"" | sudo tee -a /etc/environment
sudo mkdir -p ${APP_HOME}
sudo mkdir -p ${APP_HOME}/hf_models ${APP_HOME}/repos
sudo chown -R ubuntu:ubuntu ${APP_HOME}/hf_models ${APP_HOME}/repos
```

## Configure Ephemeral storage

```bash
#!/bin/bash
# Make models directory
sudo file -s /dev/nvme1n1
sudo mkfs -t xfs /dev/nvme1n1
sudo mount /dev/nvme1n1 ${APP_HOME}/hf_models
sudo chown ubuntu:ubuntu ${APP_HOME}/hf_models
sudo fallocate -l 512G ${APP_HOME}/hf_models/swapfile
sudo chmod 600 ${APP_HOME}/hf_models/swapfile
sudo mkswap ${APP_HOME}/hf_models/swapfile
sudo swapon ${APP_HOME}/hf_models/swapfile
mkdir ${APP_HOME}/hf_models/huggingface
ln -s ${APP_HOME}/hf_models/huggingface ${HOME}/.cache/huggingface
```

## Setup repositories

```bash
cd ${APP_HOME}/repos
git config --global credential.helper store
git lfs install
git clone https://github.com/SolidRusT/srt-model-quantizing.git
git clone https://github.com/SolidRusT/srt-inference-backends.git
git clone https://github.com/SolidRusT/srt-chat-clients.git
```

## (optional) AWQ Model Quantizing pipeline

```bash
python -m venv ${HOME}/venv-awq
source ${HOME}/venv-awq/bin/activate
pip install --upgrade -r ${APP_HOME}/repos/srt-model-quantizing/awq/requirements.txt
cp ${APP_HOME}/repos/srt-model-quantizing/awq/quant_config.json ${APP_HOME}/hf_models
cp ${APP_HOME}/repos/srt-model-quantizing/awq/run-quant-awq.py ${APP_HOME}/hf_models
deactivate
```

### Run the quant

```bash
# https://github.com/casper-hansen/AutoAWQ/blob/main/examples/quantize.py
bash s3/ready-up.sh
cd ${APP_HOME}
screen -S awq
sudo nvidia-smi -pm 1 -i 0

source ${HOME}/venv-awq/bin/activate
pip install --upgrade -r ${APP_HOME}/repos/srt-model-quantizing/awq/requirements.txt
huggingface-cli login --add-to-git-credential  --token ${HF_TOKEN}
alias quant-awq="bash ${APP_HOME}/repos/srt-model-quantizing/awq/quant-awq.sh"

quant-awq Undi95 Meta-Llama-3-8B-hf

#qant-awq.py --model_path "nbeerbower/MaidFlameSoup-7B" --quant_path "MaidFlameSoup-7B-AWQ"
deactivate
```
