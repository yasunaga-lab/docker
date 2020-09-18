IMAGE_NAME=""
HOST_NAME=""
SSH_PORT="38999"
CSPARC_PORT="39000"

docker run \
    --gpus all \
    -itd \
    --expose 22 \
    --hostname ${HOST_NAME} \
    --name ${HOST_NAME} \
    -p 127.0.0.1:${SSH_PORT}:22 \
    -p 127.0.0.1:${CSPARC_PORT}:39000 \
    -v /net/fs09/work01:/net/fs09/work01 \
    -v /net/fs09/work02:/net/fs09/work02 \
    -v /net/fs10/work01:/net/fs10/work01 \
    -v /net/fs10/work02:/net/fs10/work02 \
    -v /net/fs09/homes/people:/net/fs09/homes/people \
    -v /scratch:/scratch \
    ${IMAGE_NAME}
