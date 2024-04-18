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
cd ${APP_HOME}/repos/srt-model-quantizing
git pull
cd
cp ${APP_HOME}/repos/srt-model-quantizing/awq/* ${APP_HOME}/hf_models
python -m venv ${HOME}/venv-awq
source ${HOME}/venv-awq/bin/activate
pip install --upgrade -r ${APP_HOME}/repos/srt-model-quantizing/awq/requirements.txt
cp ${APP_HOME}/repos/srt-model-quantizing/awq/* ${APP_HOME}/hf_models
deactivate
cd ${APP_HOME}/hf_models
screen -S awq