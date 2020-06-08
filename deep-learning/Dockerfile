### Docker file for deep-learning
# version 1.1.0

### Base image
FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04

# Use bash to build this docker file
SHELL ["/bin/bash", "-c"]

### Configuration
# CUDA (must be the same as the base image's!)
ARG CUDA_TOOLKIT_VERSION=10.1
# Node.js major version
ARG NODE_VERSION=12
# Anaconda3
ARG ANACONDA_VERSION=2020.02
# Pytorch
ARG PYTORCH_VERSION=1.5.0
ARG TORCHVISION_VERSION=0.6.0
# Tensorflow
ARG TENSORFLOW_VERSION=2.1.0
ARG TENSORBOARD_VERSION=2.1.0
# cryoDRGN
ARG CRYODRGN_REPO="https://github.com/zhonge/cryodrgn.git"
ARG CRYODRGN_VERSION=0.2.1

### User account in Docker image
# username
ARG USER_NAME=""
# groupname
ARG GROUP_NAME=""
# UID
ARG USER_ID=""
# GID
ARG GROUP_ID=""
# SSH public key
ARG USER_SSH_PUBKEY=""
# Specify GID of "vglusers" group if exists, else leave this empty
ARG VGLUSERS_GROUP_ID=""

###############################################################################

# Install linux commands
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
            openssh-server \
            less \
            vim \
            sudo \
            curl \
            emacs \
            git \
            htop \
            x11-apps

# Install Node.js for jupyterlab extension
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt install -y nodejs

# SSH configuration
RUN sed -i "s/^.*PasswordAuthentication.*$/PasswordAuthentication no/" /etc/ssh/sshd_config && \
    sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config && \
    sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config && \
    ssh-keygen -A && \
    mkdir -p /var/run/sshd

# Add user
RUN groupadd -g ${GROUP_ID} ${GROUP_NAME} && \
    useradd -u ${USER_ID} -g ${GROUP_ID} -m -G sudo -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${USER_NAME}

# Set vglusers if needed
RUN if [ "${VGLUSERS_GROUP_ID}" != "" ];then \
        groupadd -g ${VGLUSERS_GROUP_ID} vglusers && \
        usermod -aG vglusers ${USER_NAME}; fi

# User environment
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
## Register SSH key
RUN mkdir .ssh && echo -e "${USER_SSH_PUBKEY}" >> .ssh/authorized_keys
## Install Anaconda
RUN wget https://repo.anaconda.com/archive/Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh && \
    bash ./Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh -b && \
    source /home/${USER_NAME}/anaconda3/etc/profile.d/conda.sh && \
    conda init bash
## Install python packages
RUN source /home/${USER_NAME}/anaconda3/etc/profile.d/conda.sh && \
    conda config --set auto_activate_base False && \
    conda config --set auto_update_conda False && \
    conda create -n dl python=3.7 && \
    conda activate dl && \
    conda install -y \
        pandas \
        seaborn \
        scikit-learn && \
    conda install -y \
        pytorch=${PYTORCH_VERSION} \
        torchvision=${TORCHVISION_VERSION} \
        cudatoolkit=${CUDA_TOOLKIT_VERSION} \
        -c pytorch && \
    conda install -y \
        tensorflow=${TENSORFLOW_VERSION} \
        tensorboard=${TENSORBOARD_VERSION} && \
    conda install umap-learn -c conda-forge && \
    conda install jupyterlab -c conda-forge && \
    pip install ipywidgets && \
    pip install cufflinks && \
    jupyter lab --generate-config && \
    jupyter lab build
## Install cryoDRGN
RUN source /home/${USER_NAME}/anaconda3/etc/profile.d/conda.sh && \
    conda activate dl && \
    mkdir softwares && cd softwares && \
    git clone ${CRYODRGN_REPO} cryodrgn && \
    cd cryodrgn && \
    git checkout ${CRYODRGN_VERSION} && \
    python setup.py install

# Create a script for running jupyterlab server
RUN echo "nohup jupyter-lab --ip=0.0.0.0 --no-browser --notebook-dir='/' --port 8888 &> .jupyterlab_log.txt < /dev/null &" > run_jupyterlab.sh && \
    chmod +x run_jupyterlab.sh

# Auto start sshd (port 22)
USER root
WORKDIR /home/${USER_NAME}
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
