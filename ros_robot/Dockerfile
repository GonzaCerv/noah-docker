# This dockerfile will be based on Ubuntu 18.04 with OpenGL installed
FROM noah/base_buster as noah_base_image_ros
ENV ROS1_DISTRO="melodic"
USER root

# Setup sources.list for ROS
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list

# Setup keys for ROS
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# Install ROS packages
RUN apt-get update && \
    apt-get install -y \
    ros-${ROS1_DISTRO}-robot \
    && \
    apt-get clean && \
    apt-get autoremove && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/doc

# Install Dependencies for working with ROS
RUN apt-get update && apt-get install --no-install-recommends -y \
    libxmlrpcpp-dev \
    librosconsole-dev \
    python-rosdep \
    python-rosinstall \
    ros-melodic-rospy-tutorials \
    ros-melodic-teleop-twist-keyboard

# Initialize rosdep
RUN rosdep init
RUN pip install --upgrade pip
USER docker
RUN rosdep update

# Read the arguments
ARG ROS_HOST="localhost"
ARG ROS_URI="http://localhost:11311"
ARG PORT=11311
EXPOSE ${PORT}

# modify bashrc
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN echo "export ROS_HOSTNAME=${ROS_HOST}.local" >> ~/.bashrc 
RUN echo "export ROS_IP=${ROS_HOST}.local" >> ~/.bashrc 
RUN echo "export ROS_MASTER_URI=${ROS_URI}" >> ~/.bashrc 

# Workspace
RUN mkdir -p /home/docker/noah_ws/src

####################################################
# Create a layer and setup mDNS
# https://github.com/Jack12816/docker-mdns
FROM noah_base_image_ros as mdns_setup
ARG ROS_HOST="nginx"
# Install required packages
USER root
RUN apt-get update -yy && \
    apt-get install -yy \
    avahi-daemon \
    avahi-discover \
    avahi-utils libnss-mdns \
    iputils-ping dnsutils
# Copy the script that runs the avahi daemon.
COPY config/avahi-daemon.conf /etc/avahi/avahi-daemon.conf
# Change the hostname of the mDNS server.
RUN sed -i "s|nginx|${ROS_HOST} |g" /etc/avahi/avahi-daemon.conf
COPY config/start.sh /
RUN chmod +x /start.sh

# Execute on start
CMD sudo /start.sh $(DOCKER_DNS_HOSTNAME) && /bin/bash

USER docker