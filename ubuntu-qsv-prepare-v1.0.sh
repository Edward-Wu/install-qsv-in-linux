#!/bin/bash

echo "--------------------------------------------"
echo "     welcome to use qsv installation"
echo "--------------------------------------------"
echo "OS  : ubuntu 18.04"
echo "gpu : intel gpu supported intel media sdk"
echo ""
echo "prepare env......"
echo "please use bash ./your_shell_file.sh"

#if use docker please load gpu devices first.
#
#1.isplay all gpu devices of host
#ls -la /dev/dri #such as:
#crw-rw----+  1 root video 226,   0 Apr 12 08:44 card0
#crw-rw----+  1 root video 226, 128 Apr 12 08:44 renderD128
#
#2.load gpu devices
#sudo docker run -it --device /dev/dri/card0:/dev/dri/card0 --device /dev/dri/renderD128:/dev/dri/renderD128 --name ffmpeg-qsv-ubuntu ubuntu:18.04 /bin/bash

#refre to https://www.cnblogs.com/lvyunxiang/p/15806424.html

#function exec_prompt, 
#$1: exec infomation
exec_prompt()
{
  echo ""
  echo "---------------------"
  echo "$1, continue, yes(y) or no(n)?"
  read x
#  if [ "$x" = "y" ]; then
  if [ "${x}" = "y" ] ; then
    echo "------- $1 -------"
  else
    # exit shell
    echo "input:$x ,abort, bye-bye!"
    exit
  fi
}


#1. tools chain
exec_prompt "1.install tools chain"
apt-get update -y
pat-get upgrade -y
apt-get install -y wget cifs-utils autoconf libtool libdrm-dev yasm libghc-x11-dev libxmuu-dev libxfixes-dev libxcb-glx0-dev libgegl-dev libegl1-mesa-dev libcogl-gles2-dev
apt-get install -y git xutils-dev libpciaccess-dev xserver-xorg-dev cmake
apt-get install -y libv4l-dev
apt-get install -y libasound2-dev
apt-get install -y libsdl2-dev 
apt-get install -y autoconf libtool libdrm-dev xorg xorg-dev openbox libx11-dev libgl1-mesa-glx libgl1-mesa-dev

apt-get install -y python3 python3-pip ninja-build
pip3 install meson
rm /usr/bin/meson
ln /usr/local/bin/meson /usr/bin/meson
meson -v

#2. update gcc c++
exec_prompt "2.update gcc c++"
apt-get install -y gcc g++
apt-get install -y libgl1-mesa-dev   libglu1-mesa-dev   freeglut3-dev  libglew-dev    libglm-dev    mesa-utils
apt-get install -y ninja-build

