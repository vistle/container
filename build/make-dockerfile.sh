#! /bin/bash

export BUILDTYPE=RelWithDebInfo
export PREFIX=/usr/local
export BUILDDIR=/build
export APTCACHE="--mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked"
export CCACHE="--mount=type=cache,target=/ccache"
export CMAKE_ARGS="-G Ninja -DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=${BUILDTYPE} -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache"


boostv=1.83.0
opencvv=410
nvctv=1.19.1

if [ "$USE_MPI" = "TRUE" ]; then
    export MPI_PACKAGES="libvtk9-dev"
else
    export MPI_PACKAGES=""
fi

case $IMAGE in
   ubuntu:14.04)
      export ARCHSUFFIX=tahropt ;;
   ubuntu:15.10)
      export ARCHSUFFIX=werewolfopt ;;
   ubuntu:16.04)
      export ARCHSUFFIX=xenialopt ;;
   *)
      export ARCHSUFFIX=linux64opt ;;
esac

cat <<EOF_packages
ARG TARGETARCH
FROM --platform=linux/amd64 library/${IMAGE} AS base_amd64
ENV ARCHSUFFIX=linux64opt
ARG CPU=corei7

FROM --platform=linux/arm64 library/${IMAGE} AS base_arm64
ENV ARCHSUFFIX=linuxarmopt
ARG CPU=native

FROM base_\${TARGETARCH} AS base
LABEL org.opencontainers.image.authors="martin.aumueller@hlrs.de"

WORKDIR /root

ARG DEBIAN_FRONTEND=noninteractive

# setup locales
RUN ${APTCACHE} apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y locales && \
  sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
  sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
  sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
  sed -i -e 's/# C.UTF-8 UTF-8/C.UTF-8 UTF-8/' /etc/locale.gen && \
  locale-gen && \
  true

ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8


FROM base AS buildenv

# install packages
RUN ${APTCACHE} apt-get install -y --no-install-recommends \
       git cmake make file \
       libtbb-dev \
       libjpeg-dev \
       libvncserver-dev \
       zlib1g-dev \
       libassimp-dev \
       libtinyxml2-dev \
       libboost-atomic-dev libboost-date-time-dev libboost-exception-dev libboost-filesystem-dev \
       libboost-iostreams-dev libboost-locale-dev libboost-log-dev libboost-math-dev libboost-program-options-dev \
       libboost-random-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev libboost-timer-dev \
       libboost-tools-dev libboost-dev \
       ispc libembree-dev \
       libopenscenegraph-dev libglew-dev \
       qt6-base-dev \
        libxerces-c-dev \
    libcatch2-dev \
    libbotan-3-dev \
    libglm-dev \
    libalut-dev libopenal-dev \
libpng-dev \
libtiff-dev \
libgdal-dev \
libproj-dev \
    bison flex libfmt-dev \
    libzip-dev \
   libturbojpeg0-dev \
libopen62541-1.4-dev libopen62541-1.4-tools \
libexiv2-dev \
libfl-dev \
libdraco-dev \
    swig libopencv-dev \
    libavcodec-dev libavformat-dev \
libtinygltf-dev \
nlohmann-json3-dev \
    g++ ninja-build \
libeigen3-dev \
    libcgal-dev \
libhwloc-dev \
${MPI_PACKAGES}


RUN ${APTCACHE} apt-get install -y --no-install-recommends \
    proj-bin xdg-user-dirs libtool opencv-data libpng-tools \
    qt6-gtk-platformtheme qt6-svg-plugins fonts-dejavu-extra \
    xauth libgdcm-tools libgdcm-dev qt6-svg-dev qt6-positioning-dev \
    qt6-location-dev qt6-declarative-dev qt6-declarative-dev-tools \
    libxkbcommon-x11-dev libqt6quickshapes6 \
    qt6-declarative-dev qt6-declarative-dev-tools qt6-declarative-private-dev \
    qt6-wayland \
    xdg-utils

FROM base AS runenv
EOF_packages

if [ -n "$XFCE" ]; then
cat <<EOF_xfce
    RUN ${APTCACHE} apt-get install -y --no-install-recommends \
        libgl1-mesa-dri mesa-utils mesa-utils-extra \
        iproute2 \
        fish \
        zsh \
        vim \
        dbus-x11 \
        xfce4-session \
        xfce4-panel \
        xfdesktop4 xfdesktop4-data xfce4 \
        xfce4-terminal \
        desktop-base desktop-file-utils fonts-quicksand keyboard-configuration \
    xdg-user-dirs \
    xauth \
    xdg-utils \
    ${BROWSER}

    #RUN ${APTCACHE} apt-get install -y --no-install-recommends  task-xfce-desktop
EOF_xfce
fi

if [ -n "$XPRA" ]; then
cat <<EOF_xpra
    RUN ${APTCACHE} apt-get install -y --no-install-recommends \
        curl
    RUN ${APTCACHE} curl https://xpra.org/get-xpra.sh | sed -e 's/sudo //' | bash
EOF_xpra
fi

if [ -n "$VNC" ]; then
vncdir=/root/.config/tigervnc
cat <<EOF_vnc
    RUN ${APTCACHE} apt-get install -y --no-install-recommends \
        tigervnc-standalone-server \
        tigervnc-tools
    RUN mkdir -p ${vncdir} && echo secret | vncpasswd -f > ${vncdir}/passwd && chown -R root:root ${vncdir} && chmod 0600 ${vncdir}/passwd
EOF_vnc
fi

if [ -n "$VGL" ]; then
cat <<EOF_vgl
    RUN ${APTCACHE} apt-get install -y --no-install-recommends \
        wget ca-certificates gpg
    RUN wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey | \
        gpg --dearmor >/etc/apt/trusted.gpg.d/VirtualGL.gpg
    RUN cd /etc/apt/sources.list.d && wget https://raw.githubusercontent.com/VirtualGL/repo/main/VirtualGL.list
    RUN ${APTCACHE} apt-get update -y && \
        apt-get install -y --no-install-recommends \
        virtualgl
EOF_vgl
fi

if [ -n "$NVIDIA" ]; then
cat <<EOF_nvidia
    RUN ${APTCACHE} apt-get install -y --no-install-recommends \
        curl ca-certificates gpg
    RUN curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
        curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' > \
        /etc/apt/sources.list.d/nvidia-container-toolkit.list
    RUN ${APTCACHE} apt-get update -y && \
        apt-get install -y --no-install-recommends \
        nvidia-container-toolkit \
        nvidia-container-toolkit-base \
        libnvidia-container-tools \
        libnvidia-container1
EOF_nvidia
fi

if [ -n "$VISTLE" -o -n "$COVISE" ]; then
cat <<EOF_build
FROM buildenv AS build

WORKDIR ${BUILDDIR}

RUN ${APTCACHE} apt-get install -y --no-install-recommends \
    ccache && \
    /usr/sbin/update-ccache-symlinks

ARG CCACHE_DIR=/ccache
RUN ${CCACHE} ccache -M 20G -s


# build OpenCOVER
RUN ${APTCACHE} apt-get install -y --no-install-recommends \
        curl ca-certificates
RUN git clone --recursive https://github.com/hlrs-vis/covise.git
RUN \
       export COVISEDIR=${BUILDDIR}/covise \
       && cd ${BUILDDIR}/covise \
       && mkdir -p build.covise \
       && cd build.covise \
       && cmake .. ${CMAKE_ARGS} -DCOVISE_CPU_ARCH=\${CPU} -DCOVISE_BUILD_ONLY_COVER=TRUE \
           -DCOVISE_WARNING_IS_ERROR=FALSE \
           -DCOVISE_USE_FORTRAN=FALSE \
           -DCOVISE_USE_MPI=${USE_MPI} \
       && cmake --build . \
       && cmake --install . \
       && echo export COVISEDIR=${PREFIX} > /etc/profile.d/covise.sh \
       && echo export ARCHSUFFIX=\${ARCHSUFFIX} >> /etc/profile.d/covise.sh \
       && echo export 'LD_LIBRARY_PATH=\${COVISEDIR}/\${ARCHSUFFIX}/lib' >> /etc/profile.d/covise.sh \
       && echo ${PREFIX}/\${ARCHSUFFIX}/lib > /etc/ld.so.conf.d/covise.conf \
       && ldconfig
RUN ${CCACHE} ccache -s

# Vistle proper
RUN git clone --recursive https://github.com/vistle/vistle.git
RUN ${CCACHE} \
       export COVISEDIR=${PREFIX} \
       && export COVISEDESTDIR=${BUILDDIR}/covise \
       && export CMAKE_PREFIX_PATH=${COVISEDIR} \
       && cd ${BUILDDIR}/vistle \
       && mkdir build.vistle \
       && cd build.vistle \
       && cmake .. ${CMAKE_ARGS} -DVISTLE_CPU_ARCH=${CPU} -DENABLE_INSTALLER=FALSE \
          -DVISTLE_USE_MPI=${USE_MPI} \
          -DVISTLE_INTERNAL_EIGEN=FALSE \
       && cmake --build . \
       && cmake --install . \
       && cd ${BUILDDIR}/vistle/install \
       && bash install-xdg.sh \
       && cd ${BUILDDIR} \
       && ldconfig
RUN ${CCACHE} \
       cd ${BUILDDIR}/vistle \
       && ls \
       && cp -r install/ ${PREFIX}/share/vistle/xdg
RUN ${CCACHE} ccache -s


FROM runenv AS run
WORKDIR /root
COPY --from=build /usr/local /usr/local
COPY --from=build /etc/ld.so.conf.d/covise.conf /etc/ld.so.conf.d/covise.conf
COPY --from=build /etc/profile.d/covise.sh /etc/profile.d/covise.sh

RUN ${APTCACHE} apt-get install -y --no-install-recommends \
    libboost-program-options${boostv} \
    libboost-filesystem${boostv} \
    libboost-atomic${boostv} libboost-date-time${boostv} libboost-filesystem${boostv} \
    libboost-iostreams${boostv} libboost-locale${boostv} libboost-log${boostv} libboost-math${boostv} libboost-program-options${boostv} \
    libboost-random${boostv} libboost-serialization${boostv} libboost-system${boostv} libboost-thread${boostv} libboost-timer${boostv} \
    libtbb12 \
    libbotan-3-7 \
    libpython3.13 \
    libopenmpi40 openmpi-bin \
    libvtk9.3 \
    libqt6widgets6 \
    libvncserver1 \
    libfmt10 \
    libgdal36 \
    libnetcdf22 \
    libglu1-mesa \
    libglew2.2 \
    libzip5 \
    libtinyxml2-11 \
    libassimp5 \
    libcurl4t64 \
    libopenscenegraph161 \
    libembree4-4 \
    libturbojpeg0 \
    libalut0 \
    libqt6network6 \
    qt6-svg-plugins \
    libgdcm-tools \
    libqt6quickshapes6 \
    libqt6openglwidgets6 \
    libqt6xml6 \
    qt6-wayland \
    libexiv2-28 \
    libopen62541-1.4 \
    libavcodec-extra libavformat-extra \
    libopencv-calib3d${opencvv} \
    libopencv-videoio${opencvv} \
    libopencv-objdetect${opencvv} \
    libopencv-contrib${opencvv} \
    proj-bin xdg-user-dirs opencv-data libpng-tools \
    qt6-gtk-platformtheme qt6-svg-plugins fonts-dejavu-extra \
    libgdcm-tools \
    xdg-utils

RUN mkdir -p /usr/share/desktop-directories 
RUN cd ${PREFIX}/share/vistle/xdg \
       && bash install-xdg.sh \

RUN ldconfig
EOF_build
fi


echo EXPOSE 5900 5901 5902 5903 31093 31094
#echo ENTRYPOINT [\"${PREFIX}/bin/vistle\"]
#echo ENTRYPOINT [\"/bin/bash\"]
#echo CMD [\"-b\"]
echo "CMD" '["vncserver", "-fg", "-localhost", "no", ":0"]'
