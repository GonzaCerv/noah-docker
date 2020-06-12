#!/usr/bin/env bash

# Author:        Gonzalo Cervetti (cervetti.g@gmail.com)
# Description:   Bash script for running the Noah container docker.
#               Refer to https://github.com/GonzaCerv/noah-docker for more information.

###### Configuration of arguments. ######
OPTIND=1
ADDITIONAL_DOCKER_ARGS=""
DOCKER_ARGS_OPT=""
reset_options="--no-cache"
build_options="--force-rm --build-arg UID=$(id -u) --build-arg GID=$(id -g)"
directory="stretch_melodic"
docker_ws="/home/docker/noah_ws"
#Source the configurations of the image
source $directory/vars.cfg

##### Definition of methods ########

#Deletes an existing image if exists
delete_image() {
    if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" != "" ]]; then
        echo "Deleting existing image" 1>&2
        docker image rm $IMAGE_NAME
    fi
}

#Builds the new image
build_image() {
    # Build docker image if not image found
    if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" == "" ]]; then
        if uname --m | grep 'x86_64' >/dev/null 2>&1; then
            echo "building for x86_64" 1>&2
            ARCH="x86_64"
        else
            echo "building for ARM" 1>&2
            ARCH="ARM"
        fi
        docker build $BUILD_ARGS $DOCKER_ARGS_OPT --tag $IMAGE_NAME "$directory"
    fi
}

#Runs the current image
run_image() {
    #Checks if image exists
    if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" != "" ]]; then
        # Get current directory, no matter from where the script is called
        SOURCE="${BASH_SOURCE[0]}"
        while [ -h "$SOURCE" ]; do
            DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
            SOURCE="$(readlink "$SOURCE")"
            [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
        done
        repo_dir="$(cd -P "$(dirname "$SOURCE")" && pwd)/${directory}"

        echo "${repo_dir}"

        XAUTH=/tmp/.docker.xauth
        xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

        DOCKER_MOUNT_ARGS="\
        -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
        -v ${REPO_DIR}:/catkin_ws/src/Noah"

        DOCKER_CAPABILITIES="--ipc=host \
        --cap-add=IPC_LOCK \
        --cap-add=sys_nice \
        -p 5901:5901"

        # if using nvidia, automatically select that image
        GRAPHICS_FLAG="--device=/dev/dri:/dev/dri"
        if [[ $IMAGE_NAME = *"nvidia"* ]]; then
            GRAPHICS_FLAG= " --runtime=nvidia"
        fi

        DOCKER_NETWORK="--net=host"
        # Start Docker container
        xhost +
        docker run --name ${CONTAINER_NAME} --privileged --rm \
            ${DOCKER_CAPABILITIES} \
            ${DOCKER_MOUNT_ARGS} \
            -v /etc/fstab:/etc/fstab:ro \
            -e ROS_HOSTNAME=localhost \
            ${GRAPHICS_FLAG} \
            ${DOCKER_NETWORK} \
            ${ADDITIONAL_DOCKER_ARGS} \
            --env="DISPLAY=$DISPLAY" \
            -v "/etc/localtime:/etc/localtime:ro" \
            --volume="${repo_dir}/../../:${docker_ws}/src/:rw" \
            --user=docker \
            -w /home/docker/noah_ws \
            -it ${IMAGE_NAME}
        xhost -

    else
        echo "No image found!" 1>&2
    fi
}

#Attach to running container
attach_image() {
    docker exec -it $CONTAINER_NAME bash
}

while getopts ":adbrz" option; do
    case "${option}" in
    a)
        attach_image
        ;;
    d)
        delete_image
        ;;
    b)
        build_image
        ;;
    r)
        run_image
        ;;
    z)
        delete_image
        build_image
        run_image
        ;;
    \?)
        echo "script usage: $(basename $0) [-d][-r][-b]" >&2
        echo "Set no parameter for automatic mode." >&2

        ;;
    esac
done
if (($OPTIND == 1)); then
    echo "Automatic mode" >&2
    if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" == "" ]]; then
        echo "action: build image" >&2
        build_image
        run_image
    elif [[ "$(docker container ls | grep $IMAGE_NAME 2>/dev/null)" != "" ]]; then
        echo "action: attach to container" >&2
        attach_image
    else
        echo "action: running image" >&2
        run_image
    fi
fi
shift $((OPTIND - 1))
