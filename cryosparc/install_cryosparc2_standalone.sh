cd /home/USER_NAME/softwares/cryosparc/cryosparc2_master
if [ -z CSPARC_SSDPATH ]; then
    cd /home/USER_NAME/softwares/cryosparc/cryosparc2_master
    ./install.sh
        --yes \
        --standalone \
        --license CSPARC_LICENSE \
        --worker_path /home/USER_NAME/softwares/cryosparc/cryosparc2_worker \
        --cudapath /usr/local/cuda-10.1 \
        --nossd \
        --initial_email CSPARC_EMAIL \
        --initial_password CSPARC_PASS \
        --initial_name "CSPARC_NAME"
else
    ./install.sh \
        --yes \
        --standalone \
        --license CSPARC_LICENSE \
        --worker_path /home/USER_NAME/softwares/cryosparc/cryosparc2_worker \
        --cudapath /usr/local/cuda-10.1 \
        --ssdpath CSPARC_SSDPATH \
        --initial_email CSPARC_EMAIL \
        --initial_password CSPARC_PASS \
        --initial_name "CSPARC_NAME"
fi
echo 'export PATH=/home/USER_NAME/softwares/cryosparc/cryosparc2_master/bin:$PATH' >> ~/.bashrc
echo ''
echo '****************************************'
echo 'To launch cryosparc, type below commands.'
echo 'source .bashrc && cryosparcm restart'
