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

## (optional) vLLM installation

```bash
cd ${APP_HOME}/repos
pyenv local 3.11
python -m venv ~/venv-vllm
source ~/venv-vllm/bin/activate
pip install vllm wheel
MAX_JOBS=4 pip install flash-attn --no-build-isolation
deactivate
```

### Running vLLM

```bash
source ~/venv-vllm/bin/activate
python -m vllm.entrypoints.openai.api_server \
--port 5000 \
--download-dir /opt/openbet/inference/hf_models \
--model cognitivecomputations/dolphin-2.8-mistral-7b-v02 \
--tokenizer cognitivecomputations/dolphin-2.8-mistral-7b-v02 \
--tokenizer-mode auto \
--dtype bfloat16 \
--api-key token-abc123 \
--swap-space 24 \
--gpu-memory-utilization 0.98 \
--max-model-len 31104
deactivate
```

### Running vLLM multi-GPU

```bash
source ~/venv-vllm/bin/activate
python -m vllm.entrypoints.openai.api_server \
--port 5000 \
--download-dir /opt/openbet/inference/hf_models \
--model cognitivecomputations/dolphin-2.8-mistral-7b-v02 \
--tokenizer cognitivecomputations/dolphin-2.8-mistral-7b-v02 \
--tokenizer-mode auto \
--dtype float32 \
--api-key token-abc123 \
--swap-space 24 \
--worker-use-ray \
--tensor-parallel-size 4

deactivate
```

### Running vLLM multi-GPU Hermes

```bash
source ~/venv-vllm/bin/activate
python -m vllm.entrypoints.openai.api_server \
--port 5000 \
--download-dir /opt/openbet/inference/hf_models \
--model NousResearch/Hermes-2-Pro-Mistral-7B \
--tokenizer NousResearch/Hermes-2-Pro-Mistral-7B \
--tokenizer-mode auto \
--dtype float32 \
--api-key token-abc123 \
--swap-space 24 \
--worker-use-ray \
--tensor-parallel-size 4

deactivate
```

### Run the tests

```bash
curl http://inference.ca.obenv.net:5000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token-abc123" \
  -d '{
     "model": "cognitivecomputations/dolphin-2.8-mistral-7b-v02",
     "messages": [{"role": "user", "content": "Holy wow, my cool AI friend from the future! This is an inference test!"}],
     "temperature": 0.7
   }'
```

## (optional) AWQ Model Quantizing pipeline

```bash
cd ${APP_HOME}/repos/srt-model-quantizing/awq
python -m venv ${HOME}/venv-awq
source ${HOME}/venv-awq/bin/activate
pip install --upgrade -r requirements.txt
cp quant_config.json ${APP_HOME}/hf_models
cp run-quant-awq.py ${APP_HOME}/hf_models
deactivate
mkdir ${APP_HOME}/hf_models/huggingface
ln -s ${APP_HOME}/hf_models/huggingface ${HOME}/.cache/huggingface
```

### Run the quant

```bash
# https://github.com/casper-hansen/AutoAWQ/blob/main/examples/quantize.py
cd ${APP_HOME}/hf_models
screen -S awq
source ~/venv-awq/bin/activate
PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True python run-quant-awq.py
```
