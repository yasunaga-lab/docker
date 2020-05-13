### Docker file for deep-learning
# version 1.0.0

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
            git

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
RUN mkdir .ssh && echo -e "${USER_SSH_PUBKEY}" >> .ssh/authorized_keys && \
    wget https://repo.anaconda.com/archive/Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh && \
    bash ./Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh -b && \
    source /home/${USER_NAME}/anaconda3/etc/profile.d/conda.sh && \
    conda init bash
RUN source /home/${USER_NAME}/anaconda3/etc/profile.d/conda.sh && \
    conda config --set auto_activate_base False && \
    conda config --set auto_update_conda False && \
    conda create -n dl && \
    conda activate dl && \
    conda install -y \
        pytorch=${PYTORCH_VERSION} \
        torchvision=${TORCHVISION_VERSION} \
        cudatoolkit=${CUDA_TOOLKIT_VERSION} \
        tensorflow=${TENSORFLOW_VERSION} \
        tensorboard=${TENSORBOARD_VERSION} \
        -c pytorch -c defaults -c conda-forge

# Create script for running jupyterlab server
RUN echo "nohup jupyter-lab --ip=0.0.0.0 --no-browser --notebook-dir='/' --port 8888 &> .jupyterlab_log.txt < /dev/null &" > run_jupyterlab.sh && \
    chmod +x run_jupyterlab.sh

# Auto start sshd (port 22)
USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
