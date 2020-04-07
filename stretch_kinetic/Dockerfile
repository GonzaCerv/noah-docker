FROM debian:stretch

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
      && apt-get clean

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8 

# RUN export LANGUAGE=en_US.UTF-8 ; export LANG=en_US.UTF-8 ; export LC_ALL=en_US.UTF-8 ; locale-gen en_US.UTF-8 ; locale-gen "en_US.UTF-8" ; dpkg-reconfigure locales 

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

# Install ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu stretch main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt-get update &&  apt-get upgrade -y  && apt-get install -y \
  python-rosdep \
  python-rosinstall-generator \
  python-wstool \ 
  python-rosinstall \
  build-essential \
  cmake 

RUN rosdep init
USER docker
RUN rosdep update

# Create workspace for ROS
RUN mkdir -p ~/ros_catkin_ws
RUN   cd ~/ros_catkin_ws; \
      rosinstall_generator desktop --rosdistro kinetic --deps --wet-only --tar > kinetic-desktop-wet.rosinstall ;\
      wstool init src kinetic-desktop-wet.rosinstall
USER docker

# Resolve dependencies
RUN mkdir -p ~/ros_catkin_ws/external_src
USER root
RUN   cd ~/ros_catkin_ws/external_src ; \
      wget http://sourceforge.net/projects/assimp/files/assimp-3.1/assimp-3.1.1_no_test_models.zip/download -O assimp-3.1.1_no_test_models.zip ; \
      unzip assimp-3.1.1_no_test_models.zip ; \
      cd assimp-3.1.1 ; \
      cmake . ; \
      make ; \
      make install 
USER docker
RUN cd ~/ros_catkin_ws; rosdep install -y --from-paths src --ignore-src --rosdistro kinetic -r --os=debian:stretch
USER root
RUN cd /home/docker/ros_catkin_ws; ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic
USER docker

RUN mkdir -p /home/docker/ws/src

COPY build_ws /home/docker/ws