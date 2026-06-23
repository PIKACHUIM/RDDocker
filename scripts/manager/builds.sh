#!/bin/bash
source scripts/manager/titles.sh
source scripts/creator/Select-Systems.sh
source scripts/creator/Select-Desktop.sh

source scripts/manager/titles.sh
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
  source scripts/manager/titles.sh
elif [ $CONFIRM == 'n' ]; then
  echo "   Warn: Not Confirmed, Exit"
  exit 0
fi

# Build ---------------------------------------------------
source scripts/manager/titles.sh
sudo docker buildx create --use \
     --name insecure-builder \
     --buildkitd-flags '--allow-insecure-entitlement security.insecure'
# 	 --no-cache 
sudo proxychains4 docker buildx build ${ISCACHE} \
     --progress=plain \
     --allow security.insecure \
     -f dockers/${OS_TYPE}/desktops/${DC_FILE} \
     -t pikachuim/${OS_TYPE}:${VERSION}-${GUI_ENV} \
     --build-arg OS_VERSION=${VERNAME} \
	   --build-arg OS_VERSHOW=${VERSION} \
	   --build-arg OS_SYSTEMS=${OS_TYPE} \
     --load\
     ./dockers \
&& \
sudo docker push \
     pikachuim/${OS_TYPE}:${VERSION}-${GUI_ENV}
echo "     ======================= Enter to back to menu ========================"
read KEY

