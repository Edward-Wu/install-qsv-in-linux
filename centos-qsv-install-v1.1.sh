#!/bin/bash

echo "--------------------------------------------"
echo "     welcome to use qsv installation"
echo "--------------------------------------------"
echo "OS  : centos:7.6.1810"
echo "gpu : intel gpu supported intel media sdk"
echo ""
echo ""
echo "install ......"

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


skip="n"
cpu_num=$(cat /proc/cpuinfo | grep processor | wc -l)
echo "cpu num is $cpu_num"

#function exec_prompt, 
#$1: exec infomation
exec_prompt()
{
  echo ""
  echo "---------------------"
  echo "$1, continue, yes(y), no(n) or (skip)?"
  skip="n"

  read x
  if [ "$x" == "y" ]; then
    echo "------- $1 -------"
  else
    if [ "$x" == "s" ]; then
      skip="y"  
    else
      # exit shell
      echo "abort, bye-bye!"
      exit
    fi
  fi
}

export LIBVA_DRIVER_NAME=iHD
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/intel/mediasdk/lib64/pkgconfig:/opt/intel/mediasdk/lib/pkgconfig:/usr/local/lib/pkgconfig
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/intel/mediasdk/lib:/opt/intel/mediasdk/lib64:/usr/local/lib:/usr/lib64

#3.install libdrm
exec_prompt "3.install libdrm"
if [ "$skip" == "n" ]; then
  git clone https://gitlab.freedesktop.org/mesa/drm.git
  cd drm
  meson builddir/ 
  ninja -C builddir/ install
  cd ..
fi

#第四步:安装2D Driver(xf86-video-intel)
exec_prompt "4.install 2d driver"
if [ "$skip" == "n" ]; then
  git clone https://gitlab.freedesktop.org/xorg/driver/xf86-video-intel.git
  cd xf86-video-intel
  ./autogen.sh
  make -j4
  make install
  cd ..
fi
 
#第五步:安装GMMLib
exec_prompt "5.install gmmlib"
if [ "$skip" == "n" ]; then
  git clone https://github.com/intel/gmmlib.git
  cd gmmlib/
  # (切换到20.4.1 tag,这一步很重要，各个仓库的版本存在对应关系)
  git checkout intel-gmmlib-20.4.1      
  mkdir build
  cd build
  cmake3  ..
  make -j8
  make install
  cd ../..
fi

#第六步:安装VAAPI and Video Driver（libva）
exec_prompt "6.install libva"
if [ "$skip" == "n" ]; then
  git clone https://github.com/intel/libva.git
  cd libva
  git checkout 2.10.0
  ./autogen.sh
  make -j8
  make install
  cd ..
fi

 
#第七部:安装Libva-Utils
exec_prompt "7.install libva-utils"
if [ "$skip" == "n" ]; then
  git clone https://github.com/intel/libva-utils.git
  cd libva-utils
  git checkout 2.10.0
  ./autogen.sh
  make -j8
  make install
  cd ..
fi

#第八步：安装Video Driver
exec_prompt "8.install video driver"
if [ "$skip" == "n" ]; then
wget https://github.com/intel/media-driver/archive/refs/tags/intel-media-20.4.5.tar.gz
tar xzvf intel-media-20.4.5.tar.gz
cd media-driver-intel-media-20.4.5
mkdir build
cd build
cmake3 ..
make -j8
make install
cd ../..
fi
 
#第九步：安装media sdk
exec_prompt "9.nstall media sdk"
if [ "$skip" == "n" ]; then
git clone https://github.com/Intel-Media-SDK/MediaSDK.git
cd MediaSDK
git checkout -b intel-mediasdk-20.5 origin/intel-mediasdk-20.5
mkdir build
cd build
cmake3 ..
make -j8
make install
cd ../..
fi


#第十步：安装libmfx
exec_prompt "10.intsll libmfx"
if [ "$skip" == "n" ]; then
yum install -y libmfx libmfx-devel
#run vainfo, check vaapi 
exec_prompt "exec vainfo"
vainfo
fi

#第十一步：安装x265
exec_prompt "11.install x265"
if [ "$skip" == "n" ]; then
git clone https://bitbucket.org/multicoreware/x265_git.git
cd x265_git/build/linux
cmake --enable-shared ../../source -DCMAKE_INSTALL_PREFIX=/opt/intel/mediasdk/
make -j8
make install
cd ../../../
fi

#第十二步：安装x264
exec_prompt "12.install x264"
if [ "$skip" == "n" ]; then
git clone https://code.videolan.org/videolan/x264.git
cd x264
./configure --enable-shared --disable-asm --prefix=/opt/intel/mediasdk/
make -j8
make install
cd ..
fi

 
#第十三步：编译ffmpeg
exec_prompt "13.install ffmpeg"
if [ "$skip" == "n" ]; then
git clone https://gitee.com/mirrors/ffmpeg.git
cd ffmpeg
./configure --enable-encoder=h264_qsv --enable-decoder=h264_qsv --enable-encoder=hevc_qsv --enable-decoder=hevc_qsv --enable-libmfx --enable-libfreetype --enable-libx264 --enable-libx265 --enable-gpl
make -j8
make install
cd ..
fi

#第十四步：测试
exec_prompt "14.run ffmpeg"
ffmpeg



