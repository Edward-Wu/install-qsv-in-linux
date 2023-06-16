#!/bin/bash

echo "--------------------------------------------"
echo "     welcome to use qsv installation"
echo "--------------------------------------------"
echo "OS  : ubuntu 18.04"
echo "gpu : intel gpu supported intel media sdk"
echo ""
echo ""
echo "install ......"
echo "please use bash ./your_shell_file.sh"

#if use docker please load gpu devices first.
#
#1.display all gpu devices of host
#ls -la /dev/dri #such as:
#crw-rw----+  1 root video 226,   0 Apr 12 08:44 card0
#crw-rw----+  1 root video 226, 128 Apr 12 08:44 renderD128
#
#2.load gpu devices
#sudo docker run -it --device /dev/dri/card0:/dev/dri/card0 --device /dev/dri/renderD128:/dev/dri/renderD128 --name ffmpeg-qsv-ubuntu ubuntu:18.04 /bin/bash

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
  echo "$1, continue, yes(y), no(n) or skip(s)?"
  skip="n"

  read x
  if [ "${x}" = "y" ]; then
    echo "------- $1 -------"
  else
    if [ "${x}" = "s" ]; then
      skip="y"  
    else
      # exit shell
      echo "input: ${x}, abort, bye-bye!"
      exit
    fi
  fi
}

sudo mkdir -p $ROOT_INSTALL_DIR

export ROOT_INSTALL_DIR=/opt/intel/mediasdk/
export LIBVA_DRIVER_NAME=iHD
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/intel/mediasdk/lib64/pkgconfig:/opt/intel/mediasdk/lib/pkgconfig:/usr/local/lib/pkgconfig
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ROOT_INSTALL_DIR/lib/mfx/:$ROOT_INSTALL_DIR/lib/xorg/:/opt/intel/mediasdk/lib:/opt/intel/mediasdk/lib64:/usr/local/lib:/usr/lib64
export LDFLAGS="-L$ROOT_INSTALL_DIR/lib"
export CPPFLAGS="-I$ROOT_INSTALL_DIR/include $CPPFLAGS"
export CFLAGS="-I$ROOT_INSTALL_DIR/include $CFLAGS"
export CXXFLAGS="-I$ROOT_INSTALL_DIR/include $CXXFLAGS"
export PATH=$ROOT_INSTALL_DIR/share/mfx/samples/:$ROOT_INSTALL_DIR/bin:$PATH
export LIBVA_DRIVERS_PATH=/usr/local/lib/dri


#4.install libdrm
exec_prompt "4.install libdrm"
if [ "$skip" = "n" ]; then
  if [ ! -d drm ]; then
    git clone https://gitlab.freedesktop.org/mesa/drm.git
  fi
  cd drm
  meson builddir/
  sudo ninja -C builddir/ install
  cd ..
fi

#5.install libva
exec_prompt "5.install libva"
if [ "$skip" = "n" ]; then
  if [ ! -d libva ]; then
    git clone https://github.com/intel/libva.git
    cd libva
    git checkout 2.10.0
    cd ..
  fi
  cd libva
  ./autogen.sh
  make -j8
  sudo make install
  cd ..
fi

#install GMMLib
exec_prompt "6.install gmmlib"
if [ "$skip" = "n" ]; then
  if [ ! -d gmmlib ]; then
    git clone https://github.com/intel/gmmlib.git
    cd gmmlib/
    # (切换到20.4.1 tag,这一步很重要，各个仓库的版本存在对应关系)
    git checkout intel-gmmlib-20.4.1      
    mkdir build
    cd ..
  fi
  cd gmmlib/build
  cmake  ..
  make -j8
  sudo make install
  cd ../..
fi

#第七部:安装Libva-Utils
exec_prompt "7.install libva-utils"
if [ "$skip" = "n" ]; then
  if [ ! -d libva-utils ]; then
    git clone https://github.com/intel/libva-utils.git
    cd libva-utils
    git checkout 2.10.0
    cd ..
  fi
  cd libva-utils
  ./autogen.sh
  make -j8
  sudo make install
  cd ..
fi

#第八步：安装Video Driver
exec_prompt "8.install video driver"
if [ "$skip" = "n" ]; then
  if [ ! -f intel-media-20.4.5.tar.gz ]; then
    wget https://github.com/intel/media-driver/archive/refs/tags/intel-media-20.4.5.tar.gz
    tar xzvf intel-media-20.4.5.tar.gz
    cd media-driver-intel-media-20.4.5
    #git clone https://github.com/intel/media-driver
    #cd media-driver
    mkdir build_media && cd build_media
    cd ..
  fi
  cd media-driver-intel-media-20.4.5/build_media
  cmake ..
  make -j$cpu_num
  sudo make install
  cd ../..
fi
 
#第九步：安装media sdk
exec_prompt "9.install media sdk"
if [ "$skip" = "n" ]; then
  if [ ! -d MediaSDK ]; then
    git clone https://github.com/Intel-Media-SDK/MediaSDK.git
    cd MediaSDK
    git checkout -b intel-mediasdk-20.5 origin/intel-mediasdk-20.5
    mkdir build
  fi
  cd MediaSDK/build
  cmake ..
  make -j8
  sudo make install
  cd ../..
fi


#第十步：安装libmfx
exec_prompt "10.install libmfx"
if [ "$skip" = "n" ]; then
  sudo apt-get install libmfx1 libmfx-tools -y
  sudo apt-get install libva-dev libmfx-dev intel-media-va-driver-non-free -y
  sudo apt-get install vainfo -y
  export XDG_RUNTIME_DIR=/usr/lib/
  #run vainfo, check vaapi 
  exec_prompt "exec vainfo"
  vainfo
fi

#第十一步：安装x265
exec_prompt "11.install x265"
if [ "$skip" = "n" ]; then
  if [ ! -d x265_git ]; then
    git clone https://bitbucket.org/multicoreware/x265_git.git
  fi
  cd x265_git/build/linux
  cmake --enable-shared ../../source -DCMAKE_INSTALL_PREFIX=/opt/intel/mediasdk/
  make -j8
  sudo make install
  cd ../../../
fi

#第十二步：安装x264
exec_prompt "12.install x264"
if [ "$skip" = "n" ]; then
  if [ ! -d x264 ]; then
    git clone https://code.videolan.org/videolan/x264.git
  fi
  cd x264
  ./configure --enable-shared --disable-asm --prefix=/opt/intel/mediasdk/
  make -j8
  sudo make install
  cd ..
fi

 
#第十三步：编译ffmpeg
exec_prompt "13.install ffmpeg"
if [ "$skip" = "n" ]; then
  if [ ! -d ffmpeg ]; then
    git clone https://gitee.com/mirrors/ffmpeg.git
  fi
  cd ffmpeg
  ./configure --enable-encoder=h264_qsv --enable-decoder=h264_qsv --enable-encoder=hevc_qsv --enable-decoder=hevc_qsv --enable-libmfx --enable-libfreetype --enable-gpl
  make -j8
  cd ..
fi

#第十四步：测试
exec_prompt "14.run ffmpeg"
./ffmpeg/ffmpeg



