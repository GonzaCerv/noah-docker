#!/usr/bin/env bash

# Author:        Gonzalo Cervetti (cervetti.g@gmail.com)
# Description:   Bash script for running the Noah container docker.
#               Refer to https://github.com/GonzaCerv/noah-docker for more information.

###### Configuration of arguments. ######
OPTIND=1
DOCKER_ARGS_OPT=""
BASE_IMAGE_DIR="buster"
BASE_IMAGE_NAME="noah/base_buster"
ROS_IMAGE=""
IMAGE_NAME="noah/"
CONTAINER_NAME=""
DIRECTORY_SUFFIX=""
DOCKER_WS="/home/docker/noah_ws"
ACTION=""
DOCKER_GPU_ARGS=""
ROS_HOSTNAME="localhost"
ROS_PORT="11311"
ROS_MASTER_URI="http://localhost:11311"


##### Definition of methods ########

#This method automatically checks the system and chooses whether to use
#the devel or image robot.
detect_capabilities() {
    echo "- Detecting capabilities of your system" 1>&2

    # Check information of the kernel to know if it is x86_64 or ARM
    if uname --m | grep 'x86_64' >/dev/null 2>&1; then
        echo "Architecture: x86_64" 1>&2
        BASE_IMAGE_DIR="${BASE_IMAGE_DIR}_x86_64"
        # If the type of build hasn't been forced yet
        if [ -z "${ROS_IMAGE}" ]; then
            local amount_of_ram=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
            # If the amount of ram is greater than 5gb, build for devel.
            if (( $amount_of_ram > 5242880 )); then
                echo "Environment: devel" 1>&2
                ROS_IMAGE="ros_desktop_full"
            else
                echo "Environment: robot" 1>&2
                ROS_IMAGE="ros_robot"
            fi
        fi
    # Devel image on ARM architecture is not yet supported 
    else
        if [[ $ROS_IMAGE == "ros_desktop_full" ]]; then
            echo "This script does not support ROS desktop full on ARM. Forcing to ROS robot. " 1>&2
        fi
        echo "Architecture: ARM" 1>&2
        echo "Environment: robot" 1>&2
        BASE_IMAGE_DIR="${BASE_IMAGE_DIR}_arm"
        ROS_IMAGE="ros_robot"
    fi

    # Check if docker can run with nvidia containers
    if dpkg --get-selections | grep 'nvidia-container-toolkit' >/dev/null 2>&1; then
        if [[ $BASE_IMAGE_DIR == "buster_arm" ]]; then
            DOCKER_GPU_ARGS="--runtime nvidia "
        else
            DOCKER_GPU_ARGS="--gpus all "
        fi
        echo "Nvidia runtime: enabled" 1>&2
        BASE_IMAGE_DIR="${BASE_IMAGE_DIR}_nvidia"
    else
        DOCKER_GPU_ARGS="--device=/dev/dri:/dev/dri "
        echo "Nvidia runtime: disabled" 1>&2
    fi
    CONTAINER_NAME="${BASE_IMAGE_DIR}_${ROS_IMAGE}"
    IMAGE_NAME="${IMAGE_NAME}${CONTAINER_NAME}"
}

#Deletes an existing image if exists
delete_image() {
    # Delete base image.
    if [[ "$(docker images -q $BASE_IMAGE_NAME 2>/dev/null)" != "" ]]; then
        echo "Deleting existing image" 1>&2
        docker image rm $BASE_IMAGE_NAME
    fi

    # Delete final image.
    if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" != "" ]]; then
        echo "Deleting existing image" 1>&2
        docker image rm $IMAGE_NAME
    fi
}

#Builds the new image
build_image() {
    # Select the propper arguments for mdns server
    DOCKER_ARGS_OPT="$DOCKER_ARGS_OPT \
        --build-arg ROS_URI=${ROS_MASTER_URI} \
        --build-arg PORT=${ROS_PORT} \
        --build-arg UID=$(id -u)"

    if [[ $ROS_IMAGE == "ros_desktop_full" ]]; then
        DOCKER_ARGS_OPT="$DOCKER_ARGS_OPT --build-arg ROS_HOST=${ROS_HOSTNAME_DEVEL}"
    else
        DOCKER_ARGS_OPT="$DOCKER_ARGS_OPT --build-arg ROS_HOST=${ROS_HOSTNAME_ROBOT}"
    fi

    # Build base image.
    if [[ "$(docker images -q $BASE_IMAGE_NAME 2>/dev/null)" == "" ]]; then
        docker build $DOCKER_ARGS_OPT --tag $BASE_IMAGE_NAME "$BASE_IMAGE_DIR/"
    fi

    # Build ROS image on top of that.
    if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" == "" ]]; then
        docker build $DOCKER_ARGS_OPT --tag $IMAGE_NAME "$ROS_IMAGE/"
    fi
}

#Runs the current image
run_image() {
    #Checks if image exists
    if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" != "" ]]; then
        # Get current directory, no matter from where the script is called
        CURRENT_DIR=$(pwd)

        # Create autorization file for X11.
        # The fix is written here: https://github.com/lbeaucourt/Object-detection/issues/7#issuecomment-433085794
        XAUTH=/tmp/.docker.xauth
        xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

        # Arguments for mounting volumes
        DOCKER_MOUNT_ARGS="\
        -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
        -v /etc/localtime:/etc/localtime:ro \
        -v ${CURRENT_DIR}/../:${DOCKER_WS}/src/:rw \
        -v "$XAUTH:$XAUTH" \
        -v /etc/fstab:/etc/fstab:ro"

        # List all environment arguments
        DOCKER_ENV_ARGS="\
        -e XAUTHORITY=$XAUTH \
        -e DISPLAY=$DISPLAY"

        # Arguments for extra capabilities
        DOCKER_CAPABILITIES="\
        --ipc=host \
        --cap-add=IPC_LOCK \
        --cap-add=sys_nice \
        -p 5901:5901"

        # Gave access to cameras if present
        if [ -f /dev/video0 ] ; then
            echo "Enabling access to camera" 1>&2
            DOCKER_CAPABILITIES="$DOCKER_CAPABILITIES --device=/dev/video0:/dev/video0"
        fi

        DOCKER_NETWORK="--net=host"
        # Start Docker container
        xhost +
        docker run --name ${CONTAINER_NAME} --privileged --rm \
            ${DOCKER_CAPABILITIES} \
            ${DOCKER_MOUNT_ARGS} \
            ${DOCKER_ENV_ARGS} \
            ${DOCKER_GPU_ARGS} \
            ${DOCKER_NETWORK} \
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

# Main -------------------------------------------------
# First get the parameters
while getopts ":aebszdr" option; do
    case "${option}" in
    a)
        ACTION="ATTACH"
        ;;
    e)
        ACTION="DELETE"
        ;;
    b)
        ACTION="BUILD"
        ;;
    s)
        ACTION="RUN"
        ;;
    z)
        ACTION="ZERO"
        ;;
    d)
        ROS_IMAGE="ros_desktop_full"
        ;;
    r)
        ROS_IMAGE="ros_robot"
        ;;
    \?)
        echo "script usage: $(basename $0) [-d][-r][-b]" >&2
        echo "Set no parameter for automatic mode." >&2
        ;;
    esac
done

# Check system hardware
detect_capabilities

# source file if exists
if [[ "$(ls | grep vars.cfg 2>/dev/null)" != "" ]]; then
    source vars.cfg
fi

# Execute the ACTION defined in the commands. If no action
# was set, then execute automatic actions.
if [[ -z "${ACTION}" ]]; then
    echo "- No action provided. Taking automatic actions" >&2
    if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" == "" ]]; then
        echo "Action: build image" >&2
        build_image
        run_image
    elif [[ "$(docker container ls | grep $IMAGE_NAME 2>/dev/null)" != "" ]]; then
        echo "Action: attach to container" >&2
        attach_image
    else
        echo "Action: run image" >&2
        run_image
    fi

elif [[ $ACTION == "ATTACH" ]]; then
    echo "Attaching image" >&2
    attach_image

elif [[ $ACTION == "DELETE" ]]; then
    echo "Deleting image" >&2
    delete_image

elif [[ $ACTION == "BUILD" ]]; then
    echo "Building image" >&2
    build_image

elif [[ $ACTION == "RUN" ]]; then
    echo "Running image" >&2
    run_image

elif [[ $ACTION == "ZERO" ]]; then
    echo "Deleting and building from zero" >&2
    delete_image
    build_image
    run_image
fi

shift $((OPTIND - 1))
