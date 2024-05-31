#!/bin/bash
source Scripts/Config.sh
source Scripts/Create/Select-Systems.sh
source Scripts/Create/Select-Desktop.sh
source Scripts/Nvidia.sh
source Scripts/Number.sh
sudo mkdir -p "${DATAPATH}${PV_DATA}/user"
sudo mkdir -p "${DATAPATH}${PV_DATA}/root"

# RUN Images ---------------------------------------------------------------------
echo -n "   Docker: "
sudo docker run -itd \
$GPU_LIST \
--privileged=true \
--shm-size=1024m \
--name $D_NAMES \
--cap-add SYS_ADMIN \
--cap-add=SYS_PTRACE \
-h $D_NAMES.$HOSTNAME \
   $PORTMAP \
-p $PM_SSHS:22 \
-p $PM_NXSR:4000 \
-p $PM_VNCS:5900 \
-v "${DATAPATH}${PV_DATA}/root:/root" \
-v "${DATAPATH}${PV_DATA}/user:/home/user" \
pikachuim/$OS_TYPE:$VERSION-$GUI_ENV

# Set Images ---------------------------------------------------------------------
if [ $GUI_ENV == 'server' ]; then
  sudo docker exec $D_NAMES /bin/bash -c "systemctl daemon-reload"
  echo -n "   "
  sudo docker exec $D_NAMES /bin/bash -c "systemctl enable run" >> /dev/null
  sudo docker exec $D_NAMES /bin/bash -c "systemctl start run" >> /dev/null
  echo -n "   Docker Restarting Container: "
  sudo docker restart $D_NAMES
fi

# Gen Passwd ---------------------------------------------------------------------
D_PASSW=$(openssl rand -hex 12)
PASS_PATH="./Backups/passwd"
SSHD_PATH="./Backups/sshkey/$D_NAMES/"
mkdir -p Backups && mkdir -p ${SSHD_PATH}
grep -v "$D_NAMES" ${PASS_PATH}.conf > ${PASS_PATH}.tmp
rm -f ${PASS_PATH}.conf && mv ${PASS_PATH}.tmp ${PASS_PATH}.conf
echo "Password: $D_NAMES $D_PASSW" >> ${PASS_PATH}.conf
ssh-keygen -f ${SSHD_PATH}id_ed25519 -t ed25519 -N '' -C $D_NAMES -q
SSH_KEY=$(cat ${SSHD_PATH}id_ed25519)
SSH_PUB=$(cat ${SSHD_PATH}id_ed25519.pub)
HOM_DIR=$(echo ~)

# Set Passwd ---------------------------------------------------------------------
sudo docker exec $D_NAMES /bin/bash -c "echo root:${D_PASSW} | chpasswd"
sudo docker exec $D_NAMES /bin/bash -c "echo user:${D_PASSW} | chpasswd"
sudo docker exec $D_NAMES /bin/bash -c "mkdir -p ~/.ssh/"
sudo docker exec $D_NAMES /bin/bash -c "mkdir -p /home/user/.ssh/"
sudo docker exec $D_NAMES /bin/bash -c "echo ${SSH_PUB} >> ~/.ssh/authorized_keys"
sudo docker exec $D_NAMES /bin/bash -c "echo ${SSH_PUB} >> /home/user/.ssh/authorized_keys"
sudo docker exec $D_NAMES /bin/bash -c "chmod 600 ~/.ssh/authorized_keys"
sudo docker exec $D_NAMES /bin/bash -c "chmod 600 /home/user/.ssh/authorized_keys"
echo "   ==========================Enter Key to Continue========================="
read KEY

# Password and Output ------------------------------------------------------------
mkdir -p ./Backups/config/
TEXT_PATH="./Backups/config/$D_NAMES.conf"
echo -e "Docker Container: ${D_NAMES}" > TEXT_PATH
source Scripts/Titles.sh
echo "──────────────────────────────────────────────────────────────────────" | tee $TEXT_PATH
echo "Congratulations! Your Docker Container has been Created Successfully! " | tee $TEXT_PATH
echo "----------------------------------------------------------------------" | tee $TEXT_PATH
echo "                 Container $D_NAMES                     "               | tee $TEXT_PATH
echo "                 OSSystem: $OS_TYPE $VERSION            "               | tee $TEXT_PATH
echo "----------------------------------------------------------------------" | tee $TEXT_PATH
echo "                 NXServer: $DOMAIN_T:$PM_NXSR    "                      | tee $TEXT_PATH
echo "                 IPV4Host: $D_NAMES.$IPV4HOST    "                      | tee $TEXT_PATH
echo "                 IPV6Host: $D_NAMES.$IPV6HOST    "                      | tee $TEXT_PATH
echo "                 HostName: $D_NAMES.$HOSTNAME    "                      | tee $TEXT_PATH
echo "----------------------------------------------------------------------" | tee $TEXT_PATH
echo "                 Username: root                         "               | tee $TEXT_PATH
echo "                 Password: $D_PASSW                     "               | tee $TEXT_PATH
echo "                 Username: user                         "               | tee $TEXT_PATH
echo "                 Password: $D_PASSW                     "               | tee $TEXT_PATH
echo "----------------------------------------------------------------------" | tee $TEXT_PATH
echo "                                                                      " | tee $TEXT_PATH
echo "Port Mapping Details:"                                                  | tee $TEXT_PATH
echo -e "       $PORTMAP_TEXT"                                                | tee $TEXT_PATH
echo "                                                                      " | tee $TEXT_PATH
echo "Container Volume Map:                                                 " | tee $TEXT_PATH
echo -e "    Host: ${DATAPATH}${PV_DATA} -> OCI: /home/user"                  | tee $TEXT_PATH
echo "                                                                      " | tee $TEXT_PATH
echo "----------------------------------------------------------------------" | tee $TEXT_PATH
echo "                                                                      " | tee $TEXT_PATH
echo "SSHLogin Private Key:"                                                  | tee $TEXT_PATH
cat ${SSHD_PATH}id_ed25519                                                    | tee $TEXT_PATH
echo "                                                                      " | tee $TEXT_PATH
echo "SSHLogin Public Key:"  								                  | tee $TEXT_PATH
awk "{print \$2}" ${SSHD_PATH}id_ed25519.pub								  | tee $TEXT_PATH
echo "                                                                      " | tee $TEXT_PATH
echo "----------------------------------------------------------------------" | tee $TEXT_PATH
echo "Note: Saved password in ./Backups/passwd.conf, please delete if need! " | tee $TEXT_PATH
echo "For any questions or suggestions, please visit:                       " | tee $TEXT_PATH
echo "                 https://github.com/PIKACHUIM/DockerFiles             " | tee $TEXT_PATH
echo "──────────────────────────────────────────────────────────────────────" | tee $TEXT_PATH
echo "======================= Enter to back to menu ========================" | tee $TEXT_PATH
read KEY
