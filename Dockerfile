FROM resin/rpi-raspbian:stretch
# target armhf for RaspberryPi 3 hard float

ENV BUILD_PATH=/tmp/build X265_VERSION=2.5 VID_STAB_VERSION=v1.1.0 FFMPEG_VERSION=3.3.4

RUN apt update \
  && apt install -y --force-yes --no-install-recommends \
   autoconf automake cmake build-essential libass-dev libfreetype6-dev \
   libtheora-dev libtool libvorbis-dev texinfo zlib1g-dev libv4l-dev libx265-dev libx264-dev \
  && rm -rf /var/lib/apt/lists/*

# libvidstab
WORKDIR ${BUILD_PATH}
ADD https://github.com/georgmartius/vid.stab/archive/${VID_STAB_VERSION}.tar.gz ${BUILD_PATH}/vid.stab-${VID_STAB_VERSION}.tar.gz
WORKDIR ${BUILD_PATH}/vid.stab
RUN tar xzf ../vid.stab-${VID_STAB_VERSION}.tar.gz -C ./ --strip-components=1
RUN cmake . && make -j$(nproc) && make -j$(nproc) install
 
# ffmpeg
WORKDIR ${BUILD_PATH}
ADD https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz ${BUILD_PATH}/ffmpeg-${FFMPEG_VERSION}.tar.xz
WORKDIR ${BUILD_PATH}/ffmpeg
RUN tar xJf ../ffmpeg-${FFMPEG_VERSION}.tar.xz -C ./ --strip-components=1
RUN ./configure --arch=armhf --target-os=linux --enable-gpl --enable-libx264 --enable-libx265 --enable-nonfree --enable-libv4l2 --enable-libvidstab && make -j$(($(nproc)/2)) && make -j$(nproc) install

# update link cache       
RUN ldconfig

# cleanup
WORKDIR /
RUN apt-get purge -y autoconf automake cmake build-essential \
  && apt-get -y --purge autoremove \
  && rm -rf ${BUILD_PATH} \

CMD ["/bin/bash"]
