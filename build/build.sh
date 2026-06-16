#! /usr/bin/env bash

#
# configuration section
#

#export IMAGE=ubuntu:26.04
export IMAGE=debian:trixie
#export IMAGE=debian:jessie
export USE_MPI=TRUE # also used as CMake arg
export XFCE=1

export VNC=1
export XPRA=
export VGL=1
export NVIDIA=1

export VISTLE=1
export COVISE=
export BROWSER=firefox-esr


#
# build Dockerfile and container
#

PUSH=
case "$1" in
    -p|--push)
        PUSH=1
        shift
        ;;
esac

bash $(dirname $0)/make-dockerfile.sh > Dockerfile

ORG=aumuell
REPO=vistle

ARCH=$(uname -m)
case $ARCH in
    aarch64)
        ARCH=arm64
        ;;
    x86_64)
        ARCH=amd64
        ;;
esac

PLAT=linux/$ARCH
TAG=$ORG/${REPO}-$ARCH:latest

docker buildx build --progress=plain --tag $TAG . || exit 1

if [ -n "$PUSH" ]; then
    docker push $TAG
fi
