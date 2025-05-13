#!/bin/bash
source Scripts/Titles.sh
source Scripts/Create/Select-Systems.sh
source Scripts/Create/Select-Desktop.sh

source Scripts/Titles.sh
echo -e "   ============================Builder Info================================"
echo -e "   Systems: $OS_TYPE";
echo -e "   Version: $VERSION";
echo -e "   Desktop: $GUI_ENV";
echo -e "   =======================================================================";
# onCache ----------------------------------------------------
echo -n "   Are you sure to use caches when build? (y/n): "
read ONCACHE
ISCACHE="--no-cache"
# ---------------------=---------------------------------------
if [ ! $CONFIRM ] || [ $ONCACHE == 'y' ]; then
  ISCACHE=""
fi
# Confirm ----------------------------------------------------
echo -n "   Are you sure to create this container? (y/n): "
read CONFIRM
# ------------------------------------------------------------
if [ ! $CONFIRM ] || [ $CONFIRM == 'y' ] ; then
  source Scripts/Titles.sh
elif [ $CONFIRM == 'n' ]; then
  echo "   Warn: Not Confirmed, Exit"
  exit 0
fi


# Choosed ----------------------------------------------------
#echo -n "   Would you like to test after building? (y/n): "
#read QCCFLAG



# Build ---------------------------------------------------
source Scripts/Titles.sh
sudo docker buildx create --use \
     --name insecure-builder \
     --buildkitd-flags '--allow-insecure-entitlement security.insecure'
# 	 --no-cache 
sudo proxychains4 docker buildx build ${ISCACHE} \
     --progress=plain \
     --allow security.insecure \
     -f Dockers/${OS_UPPE}/Desktops/${DC_FILE} \
     -t pikachuim/${OS_TYPE}:${VERSION}-${GUI_ENV} \
     --build-arg OS_VERSION=${VERNAME} \
	 --build-arg OS_VERSHOW=${VERSION} \
	 --build-arg OS_SYSTEMS=${OS_TYPE} \
     --load\
     ./Dockers \
&& \
sudo docker push \
     pikachuim/${OS_TYPE}:${VERSION}-${GUI_ENV}
echo "     ======================= Enter to back to menu ========================"
read KEY

# exit 0
# Test ----------------------------------------------------
# if [ $QCCFLAG == 'Y' ]; then
#   source Scripts/Titles.sh
#   sudo docker stop ${OS_TYPE}_${GUI_ENV}
#   sudo docker rm   ${OS_TYPE}_${GUI_ENV}
#   sudo docker run -itd \
#               --network=host \
#               --name=${OS_TYPE}_${GUI_ENV} \
#               --privileged=true \
#               --cap-add=SYS_PTRACE \
#               --shm-size=1024m \
#               --hostname=${OS_TYPE}_${GUI_ENV} \
#               pikachuim/${OS_TYPE}:${VERSION}-$GUI_ENV
#   sudo docker exec    ${OS_TYPE}_${GUI_ENV} /bin/bash -c "echo root:pika | chpasswd"
#   sudo docker exec    ${OS_TYPE}_${GUI_ENV} /bin/bash -c "echo user:user | chpasswd"
#   sudo docker exec    ${OS_TYPE}_${GUI_ENV} /bin/bash -c "systemctl daemon-reload"
#   sudo docker exec    ${OS_TYPE}_${GUI_ENV} /bin/bash -c "systemctl enable run"
#   sudo docker restart ${OS_TYPE}_${GUI_ENV}
#   sudo docker exec    ${OS_TYPE}_${GUI_ENV} /bin/bash -c "ps -ef"
#   sudo docker exec    ${OS_TYPE}_${GUI_ENV} /bin/bash -c "systemctl status run"
#   sudo docker exec    ${OS_TYPE}_${GUI_ENV} /bin/bash
# fi