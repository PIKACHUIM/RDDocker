#!/bin/bash
source Scripts/Titles.sh
# Choose System --------------------------------------------------------------------
echo "   ============================Available System============================"
echo "   [1]Ubuntu [√ Server / × Lingmo / √ GNOME / √ xfce4 / × Deepin / × IceVM]"
echo "   [2]Debian [√ Server / √ Lingmo / √ GNOME / √ xfce4 / × Deepin / × IceVM]"
echo "   [3]Apline [√ Server / × Lingmo / × GNOME / × xfce4 / × Deepin / × IceVM]"
#echo "   [3]ArchOS [√ Server / × Lingmo / × GNOME / × xfce4 / × Deepin / × IceVM]"
echo "   [4]Fedora [√ Server / × Lingmo / × GNOME / × xfce4 / × Deepin / × IceVM]"
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
#elif [ $OS_TYPE == 3 ]; then
#  source Scripts/Create/ArchOS-Version.sh
#  OS_TYPE=archos
#  OS_UPPE=ArchOS
elif [ $OS_TYPE == 3 ]; then
  source Scripts/Create/Alpine-Version.sh
  OS_TYPE=alpine
  OS_UPPE=Alpine
elif [ $OS_TYPE == 4 ]; then
  source Scripts/Create/Fedora-Version.sh
  OS_TYPE=fedora
  OS_UPPE=Fedora
fi
