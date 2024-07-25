#!/bin/bash
source Scripts/Titles.sh
# Choose System --------------------------------------------------------------------
echo "   ============================Available System============================"
echo "   [1]Ubuntu [√ Server /√ CuteOS /√ KDE /√ GNOME /√ DDE /√ OpenBox /√ xfce]"
echo "   [2]Debian [√ Server /√ CuteOS /√ KDE /√ GNOME /√ DDE /× OpenBox /× xfce]"
echo "   [3]ArchOS [√ Server /√ CuteOS /× KDE /× GNOME /× DDE /× OpenBox /× xfce]"
#echo "   [4]CentOS [√ Server /× CuteOS /× KDE /× GNOME /× DDE /× OpenBox /× xfce]"
#echo "   [5]Deepin [√ Server /√ CuteOS /√ KDE /√ GNOME /√ DDE /× OpenBox /× xfce]"
echo "   ========================================================================"
echo 
echo -n "   Choose Platforms Type Number(1): "
read OS_TYPE
if [ ! $OS_TYPE ]; then
  echo Note: OS_TYPE='[1] Ubuntu'
  sleep 3
  OS_TYPE=1
fi
if [ $OS_TYPE == 1 ]; then
  source Scripts/Create/Ubuntu-Version.sh
  OS_TYPE=ubuntu
  OS_UPPE=Ubuntu
elif [ $OS_TYPE == 2 ]; then
  source Scripts/Create/Debian-Version.sh
  OS_TYPE=debian
  OS_UPPE=Debian
elif [ $OS_TYPE == 3 ]; then
  source Scripts/Create/ArchOS-Version.sh
  OS_TYPE=archos
  OS_UPPE=ArchOS
elif [ $OS_TYPE == 4 ]; then
  source Scripts/Create/CentOS-Version.sh
  OS_TYPE=centos
  OS_UPPE=CentOS
elif [ $OS_TYPE == 5 ]; then
  source Scripts/Create/Deepin-Version.sh
  OS_TYPE=deepin
  OS_UPPE=Deepin
fi
