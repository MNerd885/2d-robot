##############
# Base image #
##############
FROM ros:jazzy-ros-base AS base

ARG DAVE_WORKSPACE_DIR="/robot2d_ws"

WORKDIR ${DAVE_WORKSPACE_DIR}
SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get -y install \
    git \
    python3-colcon-clean \
    python3-osrf-pycommon \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get -y install \
    ros-${ROS_DISTRO}-compressed-image-transport \
    ros-${ROS_DISTRO}-compressed-depth-image-transport \
    ros-${ROS_DISTRO}-image-transport \
    ros-${ROS_DISTRO}-point-cloud-transport \
    ros-${ROS_DISTRO}-point-cloud-transport-plugins \
    ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
 && rm -rf /var/lib/apt/lists/*

# Add additional installation instructions here...

ENV DEBIAN_FRONTEND=dialog


#####################
# Development image #
#####################
FROM base AS dev

ARG USERNAME="davedev"
ARG DAVE_WORKSPACE_DIR="/robot2d_ws"
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y \
    ack \
    bmon \
    cloc \
    gdb \
    htop \
    iperf3 \
    iputils-ping \
    net-tools \
    plocate \
    psmisc \
    tmux \
    xterm \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get install -y \
    python3-vcstool \
    ros-${ROS_DISTRO}-rqt-common-plugins \
    ros-${ROS_DISTRO}-rqt-robot-steering \
    ros-${ROS_DISTRO}-rqt-tf-tree \
    ros-${ROS_DISTRO}-rviz2 \
 && rm -rf /var/lib/apt/lists/*

# Install additional developer tools here...

RUN apt-get update \
 && apt-get install -y sudo \
 && rm -rf /var/lib/apt/lists/* \
 # Remove user blocking UID 1000 on Ubuntu 24.04 and onwards:
 # See https://bugs.launchpad.net/cloud-images/+bug/2005129 and
 # https://github.com/devcontainers/images/issues/1056
 && userdel -r ubuntu || true \
 && addgroup --gid ${GID} ${USERNAME} \
 && adduser --disabled-password --gecos '' --uid ${UID} --gid ${GID} ${USERNAME} \
 && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
 && chown -R ${UID}:${GID} /home/${USERNAME} \
 && chown -R ${UID}:${GID} ${DAVE_WORKSPACE_DIR}

ENV DEBIAN_FRONTEND=dialog

RUN echo "alias rsource='source ${DAVE_WORKSPACE_DIR}/install/setup.bash'" >> /home/${USERNAME}/.bash_aliases \
 && echo "alias rbuild='(cd ${DAVE_WORKSPACE_DIR} && colcon build)'" >> /home/${USERNAME}/.bash_aliases \
 && echo "alias rclean='(cd ${DAVE_WORKSPACE_DIR} && colcon clean workspace -y)'" >> /home/${USERNAME}/.bash_aliases \
 && echo "rsource || source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/${USERNAME}/.bashrc

USER ${USERNAME}