#!/bin/bash

# Config --------------------------------------------------------------------------
source Scripts/Titles.sh
echo "   ==========================Hardwares Limitation=========================="
echo "                  Set Docker CPU and Memory Limitation                     "
echo "   ========================================================================"
echo
echo -n "   Input CPU Limitation [Core](8): "
read CPUSSIZE
if [ ! $CPUSSIZE ]; then
  echo '   Note: CPUSSIZE=8'
  CPUSSIZE='8'
fi
echo -n "   Input RAM Limitation [MiBs](8192): "
read MEMSSIZE
if [ ! $MEMSSIZE ]; then
  echo '   Note: MEMSSIZE=8192'
  MEMSSIZE='8192'
fi

source Scripts/Titles.sh
echo "   ===========================Config Port Mapping=========================="
echo -n "   Enter Docker ID(Length=2 Like 01): "
read USE_PID
D_NAMES="${OCPREFIX}-${USE_PID}"
# ==================================================
PM_SSHS="${PORTRANK}${USE_PID}22";
PM_RDPS="${PORTRANK}${USE_PID}39";
PM_NXSR="${PORTRANK}${USE_PID}40";
PM_VNCS="${PORTRANK}${USE_PID}41";
PV_DATA="/OCI${USE_PID}"


# --------------------------------------------------------------------------------
#while [ ! $PM_SSHS ];
#do
#  echo -n "   Enter SSH Port Mapping(XXX): "
#  read PM_SSHS
#  if [ ! $PM_SSHS ]; then
#    echo "   Error: You must enter ssh new port!!"
#  else
#    break
#  fi
#done

# --------------------------------------------------------------------------------
IN_PORT=""
if [ "$IN_PORT" != "q" ]; then
    echo "   ===========================Configure Port Map==========================="
    echo "   Note: !!!Enter 'q' to Finish Port Mapping Input!!!"
fi
while [ "$IN_PORT" != "q" ];
do
  while [ "$IN_PORT" == "" ];
  do
    echo -n "   Enter Port Mapping(host_port:oci_port): "
    read IN_PORT
    if [ ! $IN_PORT ]; then
      echo "   Error: You need enter port map, or q to exit!!!"
    else
        break
    fi
  done
  if [ "$IN_PORT" != "q" ]; then
    PORTMAP="${PORTMAP} -p ${IN_PORT} "
  else
    break
  fi
  IN_PORT=""
done

if [ ! $PORTMAP ]; then
  TMP1MAP="-p ${PORTRANK}${USE_PID}01-${PORTRANK}${USE_PID}21:${PORTRANK}${USE_PID}01-${PORTRANK}${USE_PID}21";
  TMP2MAP="-p ${PORTRANK}${USE_PID}23-${PORTRANK}${USE_PID}38:${PORTRANK}${USE_PID}23-${PORTRANK}${USE_PID}38";
  TMP3MAP="-p ${PORTRANK}${USE_PID}42-${PORTRANK}${USE_PID}99:${PORTRANK}${USE_PID}42-${PORTRANK}${USE_PID}99";
  PORTMAP="${TMP1MAP} ${TMP2MAP} ${TMP3MAP}";
fi

# --------------------------------------------------------------------------------
while [ ! $D_NAMES ];
do
  echo -n "   Enter Docker Names(XXXXXXX): "
  read D_NAMES
  if [ ! $D_NAMES ]; then
    echo "   Error: You must enter container name"
  else
        break
  fi
done

# --------------------------------------------------------------------------------
source Scripts/Titles.sh
PORTMAP_TEXT=${PORTMAP//-\\n\\n\\n}
PORTMAP_TEXT=${PORTMAP_TEXT//-p/\\n\\t}
echo -e "   ===========================Container Info==============================="
echo -e "   Port Mapping: $PORTMAP_TEXT";
echo -e "   SSHD Porting: $PM_SSHS";
echo -e "   NXD Services: $PM_NXSR";
echo -e "   Docker  Name: $D_NAMES";
echo -e "   System  Name: $OS_TYPE";
echo -e "   System  Vers: $VERNAME";
echo -e "   Desktop Type: $GUI_ENV";
echo -e "   ========================================================================";
echo -n "   Confirm to create the container? (y/n): "
read CONFIRM
if [ ! $CONFIRM ] || [ $CONFIRM == 'n' ] ; then
  echo "   Warn: Not Confirmed, Exit"
  exit 0
elif [ $CONFIRM == 'y' ]; then
  echo -e "   ========================================================================";
fi