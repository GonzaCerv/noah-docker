FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu16.04 as nvidia
FROM ubuntu:18.04
ARG uid

# Username
ENV USER=ubuntu

# Setup environment
RUN apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV \
  LANG=en_US.UTF-8 \
  DEBIAN_FRONTEND=noninteractive \
  TERM=xterm

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    apt-utils \
    software-properties-common \
    dirmngr \
    gnupg2 \
    gnupg \
    curl \
    wget

# Setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6B05F25D762E3157

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
    bash-completion \
    build-essential \
    debian-archive-keyring \
    debian-keyring \
    desktop-file-utils \
    python-wstool \
    cmake \
    git \
    git-lfs \
    imagemagick \
    lib32gcc1 \
    libc6-i386 \
    libprotobuf-dev \
    libprotoc-dev \
    libsvm-tools \
    mercurial \
    mesa-utils \
    mosquitto \
    mosquitto-clients \
    netcat \
    openssh-server \
    pkg-config \
    protobuf-compiler \
    python-pip \
    python-shapely \
    python-vcstools \
    rapidjson-dev \
    software-properties-common \
    python3-pip python-pip  \
    dialog \
    minicom \
    nano \
    socat \
    unzip \
    xvfb \
    x11vnc \
    ssh \
    sudo \
    xterm \
    tmux

RUN apt-get install -y \
  g++ autogen autoconf graphviz \
  libboost-dev libboost-test-dev libgtest-dev libtool \
  python3-sip-dev doxygen python3-sphinx \
  python3-sphinx-rtd-theme

###############################################

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    apt-get autoremove && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/doc

# Create a user with passwordless sudo
RUN adduser --gecos "Development User" --disabled-password -u ${uid} ${USER}
RUN adduser ${USER} sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER root
# Setup environment
ENV ROS_DISTRO=melodic

# Setup sources.list for ROS
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list

# Setup keys for ROS
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# Setup sources.list for Gazebo
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -sc) main" > /etc/apt/sources.list.d/gazebo-stable.list

# Setup keys for Gazebo
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2486D2DD83DB69272AFE98867170598AF249743

# Install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-rosinstall-generator

# Install ROS packages
RUN apt-get update && \
    apt-get install -y \
    gazebo9* \
    ros-${ROS_DISTRO}-desktop-full \
    && \
    apt-get clean && \
    apt-get autoremove && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/doc

# Initialize rosdep
RUN rosdep init

RUN apt-get update && \
    apt-get install -y \
    ros-${ROS_DISTRO}-controller-manager \
    ros-${ROS_DISTRO}-hardware-interface \
    ros-${ROS_DISTRO}-joint-limits-interface \
    ros-${ROS_DISTRO}-rosbridge-server \
    ros-${ROS_DISTRO}-tf2-geometry-msgs \
    ros-${ROS_DISTRO}-transmission-interface \
    ros-${ROS_DISTRO}-teleop-twist-keyboard \
    ros-${ROS_DISTRO}-teleop-twist-joy \
    ros-${ROS_DISTRO}-twist-mux \
    ros-${ROS_DISTRO}-move-base \
    ros-${ROS_DISTRO}-cartographer-ros \
    ros-${ROS_DISTRO}-imu-filter-madgwick \
    ros-${ROS_DISTRO}-rosserial-arduino \
    && \
    apt-get clean && \
    apt-get autoremove && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/doc

# These commands fix an issue installing packages with PIP
RUN pip2 install --upgrade pip
RUN pip2 install -U setuptools wheel future
RUN pip3 install --upgrade pip
#RUN pip3 install -U setuptools wheel future

# Reduce roslaunch timeout
RUN sudo sed -i 's/_TIMEOUT_SIGTERM = 2.0/_TIMEOUT_SIGTERM = 0.5/g' /opt/ros/melodic/lib/python2.7/dist-packages/roslaunch/nodeprocess.py
RUN sudo sed -i 's/_TIMEOUT_SIGINT  = 15.0/_TIMEOUT_SIGINT  = 1.0/g' /opt/ros/melodic/lib/python2.7/dist-packages/roslaunch/nodeprocess.py

USER ${USER}

# Automatically source ROS workspace
RUN echo "source /opt/ros/melodic/setup.bash" >> /home/${USER}/.bashrc
ENV CATKIN_WS_DIR "/catkin_ws"
ENV CATKIN_SETUP_BASH "${CATKIN_WS_DIR}/devel/setup.bash"
ENV COLCON_SETUP_BASH "${CATKIN_SOURCE_DIR}/install/local_setup.bash"
RUN echo '[[ -f ${CATKIN_SETUP_BASH} ]] && . ${CATKIN_SETUP_BASH}' >> /home/${USER}/.bashrc
RUN echo '[[ -f ${COLCON_SETUP_BASH} ]] && . ${COLCON_SETUP_BASH}' >> /home/${USER}/.bashrc

USER root
# Set display
ENV DISPLAY :0

# Install Dependencies for working with ROS
RUN apt-get update &&  apt-get upgrade -y  && apt-get install -y \
  libxmlrpcpp-dev \ 
  librosconsole-dev

USER ${USER}
RUN rosdep update

# Install libserial
USER root

RUN git clone https://github.com/crayzeewulf/libserial.git
RUN cd libserial/ &&  ./compile.sh && cd build/ && make install
# Source ROS
RUN echo 'source /opt/ros/melodic/setup.bash' >> ~/.bashrc
USER ${USER}
# Source ROS
RUN echo 'source /opt/ros/melodic/setup.bash' >> ~/.bashrc

# Extra configurations
RUN mkdir -p /home/${USER}/noah_ws/src
EXPOSE 11345

USER ${USER}

COPY --from=nvidia /usr/local /usr/local
COPY --from=nvidia /etc/ld.so.conf.d/glvnd.conf /etc/ld.so.conf.d/glvnd.conf

ENV NVIDIA_VISIBLE_DEVICES=all NVIDIA_DRIVER_CAPABILITIES=all
ENTRYPOINT tmux

