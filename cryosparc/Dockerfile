# Base docker image
FROM nvidia/cuda:10.1-cudnn7-devel-centos7

# Use bash shell to build
SHELL ["/usr/bin/bash", "-c"]

# Configrations
## username of cryosparc_user
ARG USER_NAME=""
## groupname of cryosparc_user
ARG GROUP_NAME=""
## UID of cryosparc_user
ARG USER_ID=""
## GID of cryosparc_user
ARG GROUP_ID=""
## SSH public key
ARG USER_SSH_PUBKEY=""

## cryoSPARC license
ARG CSPARC_LICENSE=""
## cryoSPARC user email
ARG CSPARC_EMAIL=""
## cryoSPARC user password
ARG CSPARC_PASS=""
## cryoSPARC user name
ARG CSPARC_NAME=""
## cryoSPARC SSD path (Leave this empty if not exist)
## Replace slash with '\/' (Backslash escape)
ARG CSPARC_SSDPATH=""

###############################################################################

# Copy files. These must NOT be symlinks, but actual tarballs!!
COPY cryosparc2_master.tar.gz /tmp
COPY cryosparc2_worker.tar.gz /tmp

# Install tools and dependencies
RUN yum update -y && \
    yum groupinstall "Development tools" -y && \
    yum install -y \
        openssh-server \
        sudo \
        vim

# SSH configuration
RUN sed -i "s/^.*PasswordAuthentication.*$/PasswordAuthentication no/" /etc/ssh/sshd_config && \
    sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config && \
    sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config && \
    ssh-keygen -A

# Add user
RUN groupadd -g ${GROUP_ID} ${GROUP_NAME} && \
    useradd -u ${USER_ID} -g ${GROUP_ID} -m -G wheel ${USER_NAME} && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'Defaults:%wheel !requiretty' >> /etc/sudoers

# Change file permission
RUN chmod 777 /tmp/cryosparc2_master.tar.gz && \
    chmod 777 /tmp/cryosparc2_worker.tar.gz

# User setup
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
RUN mkdir .ssh && \
    echo -e "${USER_SSH_PUBKEY}" >> .ssh/authorized_keys && \
    echo 'export PS1="\n\[\e[33m\][\D{%H:%M:%S} \u@\h \w]\[\e[0m\]\n\[\e[1m\]>\[\e[0m\] "' >> ~/.bashrc

# Download cryoSPARC tarballs
RUN mkdir -p softwares/cryosparc && \
    cd softwares/cryosparc && \
    echo "Decompressing cryosparc2_master....." && \
    tar -xf /tmp/cryosparc2_master.tar.gz && \
    echo "Decompressing cryosparc2_worker....." && \
    tar -xf /tmp/cryosparc2_worker.tar.gz

## Install cryoSPARC
WORKDIR /home/${USER_NAME}
COPY --chown=${USER_NAME}:${GROUP_NAME} install_cryosparc2_standalone.sh .
RUN sed -i \
    -e "s/USER_NAME/${USER_NAME}/g" \
    -e "s/CSPARC_SSDPATH/${CSPARC_SSDPATH}/g" \
    -e "s/CSPARC_LICENSE/${CSPARC_LICENSE}/g" \
    -e "s/CSPARC_EMAIL/${CSPARC_EMAIL}/g" \
    -e "s/CSPARC_PASS/${CSPARC_PASS}/g" \
    -e "s/CSPARC_NAME/${CSPARC_NAME}/g" \
    install_cryosparc2_standalone.sh && \
    chmod +x install_cryosparc2_standalone.sh

# Auto start sshd (port 22)
USER root
EXPOSE 22
EXPOSE 39000
WORKDIR /home/${USER_NAME}
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
CMD ["/usr/sbin/sshd", "-D"]
