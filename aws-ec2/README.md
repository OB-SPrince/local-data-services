# ads

```bash
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
    python3.11-full \
    python3-pip \
    python3-venv \
    python3-wheel \
    git git-lfs wget unzip zip \
    ubuntu-drivers-common \
    python-is-python3 \
    pkg-config 

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo ubuntu-drivers install --gpgpu nvidia:550-server
sudo apt install cuda-toolkit nvidia-dkms-550-server nvidia-fabricmanager-550 libnvidia-nscq-550 nvidia-utils-550-server
#sudo reboot
#sudo apt dist-upgrade -y
#sudo reboot
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 100
pip install --upgrade pip
curl https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
source .bashrc
pyenv update
pyenv install 3.11
pyenv local 3.11
mkdir repos
cd repos
git clone https://github.com/OB-SPrince/local-data-services.git
git clone https://github.com/theroyallab/tabbyAPI.git
cd tabbyAPI
python -m venv ~/venv-tabbyapi
source ~/venv-tabbyapi/bin/activate
pip install --upgrade pip
pip install wheel packages
pip install -U .[cu121]
#mkdir ~/hf_models
sudo file -s /dev/nvme1n1
sudo mkfs -t xfs /dev/nvme1n1 -f
sudo mkdir /hf_models
sudo mount /dev/nvme1n1 /hf_models
sudo chown ubuntu:ubuntu /hf_models
cd /hf_models
git lfs install
git clone https://huggingface.co/cognitivecomputations/dolphin-2.8-mistral-7b-v02
rm -rf /hf_models/dolphin-2.8-mistral-7b-v02/.git
cd ~/repos/tabbyAPI

#cp ~/repos/local-data-services/aws-ec2/config.yml ~/repos/tabbyAPI/

python main.py
#sudo apt dist-upgrade -y
```
