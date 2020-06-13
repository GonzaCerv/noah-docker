####################################################
# This dockerfile will be based on Ubuntu 18.04 with OpenGL installed
FROM ubuntu:18.04 as base_image

# Set interface as non interactive to avoid dockerfile to block
# https://askubuntu.com/questions/909277/avoiding-user-interaction-with-tzdata-when-installing-certbot-in-a-docker-contai
ENV DEBIAN_FRONTEND=noninteractive

####################################################
# Create a layer and install libserial
FROM base_image as libserial
USER root
RUN apt-get update && apt-get install -y \
  g++ git autogen autoconf build-essential cmake graphviz \
  libboost-dev libboost-test-dev libgtest-dev libtool \
  python3-sip-dev doxygen python3-sphinx pkg-config \
  python3-sphinx-rtd-theme
RUN git clone https://github.com/crayzeewulf/libserial.git
RUN cd libserial/ &&  ./compile.sh && cd build/ && make install

####################################################
# Layer for environment variables and basic packages
FROM base_image as base_image_with_extra_packages

# Copy libserial from libserial layer into the new image.
COPY --from=libserial /usr/local/lib/libserial.a /usr/local/lib/
COPY --from=libserial /usr/local/lib/libserialmod.so /usr/local/lib/
COPY --from=libserial /usr/local/lib/libserial.so /usr/local/lib/
COPY --from=libserial /usr/local/lib/libserial.so.1 /usr/local/lib/
COPY --from=libserial /usr/local/lib/libserial.so.1.0.0 /usr/local/lib/
COPY --from=libserial /usr/local/include/libserial/ /usr/local/include/libserial/

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
      mesa-utils \
      minicom \
      sudo \
      tmux \
      nano \
      socat \
      unzip \
      xvfb \
      x11vnc \
      && apt-get clean

# Configure timezone and keyboard layout
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

# Open serial ports without sudo
RUN usermod -a -G dialout docker