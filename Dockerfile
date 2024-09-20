FROM osrf/ros:melodic-desktop-full

SHELL ["/bin/bash","-c"]

RUN apt-get update

RUN apt-get install -y ros-melodic-moveit \
                       ros-melodic-moveit-commander \
                       terminator

SHELL ["/bin/bash","-c"]

RUN mkdir -p /workspaces/robo_arm_ws/src

RUN apt-get update && apt install -y docker.io 

# create user with id 1001 (jenkins docker workflow default)
RUN useradd --shell /bin/bash -u 1001 -c "" -m user && usermod -a -G dialout user

RUN echo "alias docker_stop='docker stop xarm-arm'" >> ~/.bashrc

CMD ["sleep", "infinity"]