#!/bin/bash
source Scripts/Titles.sh
# Config --------------------------------------------------------------------------
echo "   ===========================Config Port Mapping=========================="
echo -n "   Enter Docker ID(Length=2 Like 01): "
read USE_PID
D_NAMES="S1V3-OCI-${USE_PID}-CD1"
# ==================================================
PM_SSHS="1${USE_PID}22";
PM_NXSR="1${USE_PID}40";
PM_VNCS="1${USE_PID}41";
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
  TMP1MAP="-p 1${USE_PID}01-1${USE_PID}21:1${USE_PID}01-1${USE_PID}21";
  TMP2MAP="-p 1${USE_PID}23-1${USE_PID}39:1${USE_PID}23-1${USE_PID}39";
  TMP3MAP="-p 1${USE_PID}42-1${USE_PID}99:1${USE_PID}42-1${USE_PID}99";
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
echo -e "   System  Vers: $VERSION";
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