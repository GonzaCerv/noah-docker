FROM ros:melodic-robot

# Environment variables and basic packages
RUN apt-get update && apt-get install -y \
      build-essential \
      dirmngr \
      curl \
      wget \
      software-properties-common \
      python3-pip python-pip  \
      dialog \
      apt-utils \
      dialog \
      locales \
      minicom \
      sudo \
      tmux \
      nano \
      socat \
      unzip \
      xvfb \
      x11vnc \
      && apt-get clean

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8 
ENV TZ=America/Argentina/Cordoba
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set display
ENV DISPLAY :0

# Set user
ARG USERNAME=docker
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID $USERNAME
RUN apt-get install  -y sudo
RUN useradd -m -u $UID -g $GID -s /bin/bash $USERNAME \
 && echo "$USERNAME:$USERNAME" | chpasswd \
 && adduser $USERNAME sudo
RUN echo "\ndocker    ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers && /usr/sbin/visudo -c

# Install Dependencies for working with ROS
RUN apt-get update &&  apt-get upgrade -y  && apt-get install -y \
  python-rosdep \
  python-rosinstall-generator \
  python-wstool \ 
  python-rosinstall \
  build-essential \
  cmake \
  libxmlrpcpp-dev \ 
  librosconsole-dev \
  ros-melodic-teleop-twist-keyboard

  USER docker
  RUN rosdep update

# Install libserial
USER root
RUN apt-get install -y \
  g++ git autogen autoconf build-essential cmake graphviz \
  libboost-dev libboost-test-dev libgtest-dev libtool \
  python3-sip-dev doxygen python3-sphinx pkg-config \
  python3-sphinx-rtd-theme
RUN git clone https://github.com/crayzeewulf/libserial.git
RUN cd libserial/ &&  ./compile.sh && cd build/ && make install
RUN usermod -a -G dialout docker
USER docker
# Source ROS
RUN echo 'source /opt/ros/melodic/setup.bash' >> ~/.bashrc

# Extra configurations
RUN mkdir -p /home/docker/noah_ws/src
EXPOSE 11345
