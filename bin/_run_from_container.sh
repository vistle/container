#! /bin/bash

export VISTLE_KEY=""

basedir="$(dirname $0)/.."
basedir="$(realpath $basedir)"

volumes="--volume $basedir/data:/data"
#volumes="--mount type=bind,src=$basedir/data,dst=/data"
#volumes="$volumes --mount type=bind,src=./home,dst=/root"

#ports="-p 31093:31093"
ports=""

cmd="$(basename $0)"
ep=--entrypoint
case "$cmd" in
    run)
        ep=""
        cmd=""
        ;;
    vnc|vnc*)
        idx=${cmd#vnc}
        if [ -z "$idx" ]; then idx=0; fi
        p=$((5900+$idx))
        cmd="vncserver"
        args="-fg -localhost no :$idx"
        ports="$ports -p $p:$p"
        ;;
    xpra)
        cmd="xpra"
        p=9876
        args="start --bind-tcp=0.0.0.0:$p --html=on --daemon=no --start=xfce4-session"
        ports="$ports -p $p:$p"
        ;;
    *)
        ;;
esac

runner="docker"
case "$(uname)" in
    Darwin)
        container --version >/dev/null && runner=container
        containerargs="-m 10G"
        ;;
    Linux)
        podman --version >/dev/null && runner=podman

        devices="--device=/dev/dri:/dev/dri"
        for d in /dev/nvidia*; do
            if [ ! -e "$d" ]; then continue; fi
            devices="$devices --device=$d:$d"
        done
        ;;
esac
if [ -n "$RUNNER" ]; then runner="${RUNNER}"; fi


ARCH=$(uname -m)
case $ARCH in
    aarch64)
        ARCH=arm64
    ;;
    x86_64)
        ARCH=amd64
    ;;
esac

function run() {
    echo "$@"
    "$@"
}

image="aumuell/vistle-${ARCH}:latest"
eval runnerargs=\"\${${runner}args}\"
case "$runner" in
    docker|podman|container)
        run $runner run \
            $devices \
            $volumes \
            $ports \
            -e VISTLE_KEY \
            --interactive --tty \
            $ep $cmd \
            ${runnerargs} \
            docker.io/$image $args "$@"
        ;;
    apptainer)
        sif=vistle-${ARCH}.sif
        run apptainer pull $sif docker://$image
        #--no-home
        run apptainer run --home /home/ma/git/vistle-docker/home --fakeroot --nv --containall \
            ${runnerargs} \
            $sif $cmd $args "$@"
        ;;
esac
