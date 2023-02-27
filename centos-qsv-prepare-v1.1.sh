#!/bin/bash

echo "--------------------------------------------"
echo "     welcome to use qsv installation"
echo "--------------------------------------------"
echo "OS  : centos:7.6.1810"
echo "gpu : intel gpu supported intel media sdk"
echo ""
echo "prepare env......"

#if use docker please load gpu devices first.
#
#1.isplay all gpu devices of host
#ls -la /dev/dri #such as:
#crw-rw----+  1 root video 226,   0 Apr 12 08:44 card0
#crw-rw----+  1 root video 226, 128 Apr 12 08:44 renderD128
#
#2.load gpu devices
#sudo docker run -it --device /dev/dri/card0:/dev/dri/card0 --device /dev/dri/renderD128:/dev/dri/renderD128 --name ffmpeg-qsv centos:7.6.1810 /bin/bash

#refre to https://www.cnblogs.com/lvyunxiang/p/15806424.html

#function exec_prompt, 
#$1: exec infomation
exec_prompt()
{
  echo ""
  echo "---------------------"
  echo "$1, continue, yes(y) or no(n)?"
  read x
  if [ "$x" == "y" ]; then
    echo "------- $1 -------"
  else
    # exit shell
    echo "abort, bye-bye!"
    exit
  fi
}


#1. tools chain
exec_prompt "1.install tools chain"
yum update -y
yum install -y gcc gcc-c++ autoconf automake m4 libpciaccess-devel epel-release cmake cmake3 pciutils bison flex elfutils-libelf-devel bc openssl-devel wget git python-make xorg-x11-server-devel libXfont2-devel expat-devel libXrandr-devel nasm SDL2 SDL2-devel meson which
yum install -y gcc gcc-c++ autoconf automake m4 libpciaccess-devel epel-release cmake cmake3 pciutils bison flex elfutils-libelf-devel bc openssl-devel wget git python-make xorg-x11-server-devel libXfont2-devel expat-devel libXrandr-devel nasm SDL2 SDL2-devel meson which
yum install -y zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel xz xz-devel expat-devel libXrandr-devel
yum install -y zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel xz xz-devel expat-devel libXrandr-devel
#yum install -y xorg-x11-server-Xorg xorg-x11-server-utils xorg-x11-utils xorg-x11-xinit
#yum install -y xorg-x11-server-Xorg xorg-x11-server-utils xorg-x11-utils xorg-x11-xinit
yum groupinstall -y  "X Window System"
yum groupinstall -y GNOME Desktop Environment
yum groupinstall -y KDE Desktop Environment

#2. update gcc c++
exec_prompt "2.update gcc c++"
yum install -y centos-release-scl scl-utils-build scl-utils
yum install -y devtoolset-7-gcc-c++.x86_64  devtoolset-8-gcc-c++.x86_64 devtoolset-9-gcc-c++.x86_64 devtoolset-10-gcc-c++.x86_64
scl enable devtoolset-8 bash

