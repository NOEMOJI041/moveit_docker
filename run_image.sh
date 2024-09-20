#!/bin/bash

# Map host's display socket to docker
DOCKER_ARGS+=("-v /tmp/.X11-unix:/tmp/.X11-unix")
# DOCKER_ARGS+=("-v $HOME/.Xauthority:/home/admin/.Xauthority:rw")
DOCKER_ARGS+=("-e DISPLAY")

xhost +local:root

container_name="kawada-arm"
image_name="kawada-arm"

if docker ps --format '{{.Names}}' | grep -q "$container_name"; then
    docker exec -it "$container_name" /bin/bash
else
    docker run -it --rm \
        ${DOCKER_ARGS[@]} \
        -e DISPLAY=$DISPLAY \
        -v $PWD/build_files:/workspaces/robo_arm_ws/ \
        -v $PWD:/workspaces/robo_arm_ws/src \
        --name "$container_name" \
        --workdir /workspaces/robo_arm_ws/ \
        --network host \
        -v /dev/input:/dev/input --device-cgroup-rule='c 13:* rmw' \
        $@ \
        "$image_name":1.0 \
        /bin/bash -c "/bin/bash"
fi
