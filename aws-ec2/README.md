# installing basic inference

Specifications:

- EC2 `g5.xlarge` instance, `g5.2xlarge` for production
- EC2 NVMe volume of 250GiB (hf_models)
- EBS `gp3` volume of 64GiB (root)
- NVIDIA a10g 24GB GPU, Compute rev. 8.6, CUDA 12.x compatible
- Ubuntu Linux 22.04-server

Potential ec2 user_data script:

```bash
# Configure local filesystem
export APP_HOME=/opt/openbet/inference
echo "APP_HOME=\"/opt/openbet/inference\"" | sudo tee -a /etc/environment
sudo mkdir -p ${APP_HOME}
sudo mkdir -p ${APP_HOME}/hf_models ${APP_HOME}/repos
sudo chown -R ubuntu:ubuntu ${APP_HOME}/hf_models ${APP_HOME}/repos
# Make models directory
sudo file -s /dev/nvme1n1
sudo mkfs -t xfs /dev/nvme1n1
sudo mount /dev/nvme1n1 ${APP_HOME}/hf_models
sudo chown ubuntu:ubuntu ${APP_HOME}/hf_models
UUID=$(blkid -s UUID -o value /dev/nvme1n1)
echo "UUID=${UUID} ${APP_HOME}/hf_models xfs defaults,nofail  0 2" | sudo tee -a /etc/fstab
# Update system
sudo apt update
sudo add-apt-repository -y universe
sudo add-apt-repository -y multiverse
sudo add-apt-repository -y restricted
sudo apt update
sudo apt-get install -y \
    build-essential \
    zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev liblzma-dev \
    curl \
    ca-certificates \
    python3-full \
    python3-pip \
    python3-venv \
    python3-wheel \
    git git-lfs wget unzip zip \
    ubuntu-drivers-common \
    python-is-python3 \
    pkg-config
# Setup NVIDIA hardware
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo ubuntu-drivers install --gpgpu nvidia:550-server
sudo apt install cuda-toolkit nvidia-dkms-550-server nvidia-fabricmanager-550 libnvidia-nscq-550 nvidia-utils-550-server
sudo reboot
```

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

```bash
# Download default model
cd ${APP_HOME}/hf_models
git lfs install
git clone https://huggingface.co/cognitivecomputations/dolphin-2.8-mistral-7b-v02
rm -rf ${APP_HOME}/hf_models/dolphin-2.8-mistral-7b-v02/.git
```

```bash
# Install local data services
cd ${APP_HOME}/repos
git clone https://github.com/OB-SPrince/local-data-services.git
git clone https://github.com/theroyallab/tabbyAPI.git
cd tabbyAPI
python -m venv ~/venv-tabbyapi
source ~/venv-tabbyapi/bin/activate
pip install --upgrade pip
pip install wheel packages
pip install -U .[cu121]
cp ${APP_HOME}/repos/local-data-services/aws-ec2/config.yml ${APP_HOME}/repos/tabbyAPI/
cp ${APP_HOME}/repos/local-data-services/aws-ec2/api_tokens.yml ${APP_HOME}/repos/tabbyAPI/
deactivate
```

```bash
cd ${APP_HOME}/repos/tabbyAPI
source ~/venv-tabbyapi/bin/activate
python main.py
deactivate
```

```bash
curl http://inference.ca.obenv.net:5000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-someshit" \
  -d '{
     "model": "not-required",
     "messages": [{"role": "user", "content": "Holy wow, my cool AI friend from the future! This is an inference test!"}],
     "temperature": 0.7
   }'
```
