#!/bin/bash

# Map host's display socket to docker
DOCKER_ARGS+=("-v /tmp/.X11-unix:/tmp/.X11-unix")
# DOCKER_ARGS+=("-v $HOME/.Xauthority:/home/admin/.Xauthority:rw")
DOCKER_ARGS+=("-e DISPLAY")
# DOCKER_ARGS+=("-e NVIDIA_VISIBLE_DEVICES=all")
# DOCKER_ARGS+=("-e NVIDIA_DRIVER_CAPABILITIES=all")
# DOCKER_ARGS+=("-e FASTRTPS_DEFAULT_PROFILES_FILE=/usr/local/share/middleware_profiles/rtps_udp_profile.xml")

xhost +local:root

image_name="kawada-arm"
container_name="kawada-arm"

# Initialize variables
force_option=false 
clean_option=false
clean_option=false
offline_option=false


# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      force_option=true
      shift
      ;;

    --clean)
      clean_option=true
      shift
      ;;

    --offline)
      offline_option=true
      shift
      ;;
      
    *)
      echo "Invalid option: $1"
      exit 1
      ;;
  esac
done


  if docker images --format '{{.Repository}}' | grep -q "$image_name"; then

      image_id=$(docker images --format '{{.ID}}' --filter=reference="$image_name")
      echo "Older Image ID: $image_id"

      echo "Found Docker Image: $image_name:1.0"

      if $force_option; then
        echo "*****Buidling Existing Docker Image: $image_name*****"
        docker build -f Dockerfile -t "$image_name":1.0 .

      elif $offline_option; then
        echo "*****Buidling OFFLEINE DOCKER FILE: $image_name*****"
        docker build -f DockerfileOffline -t "$image_name":1.0 .
        docker rmi $image_id

      else

        run_command='catkin_make && exit'

        if $clean_option; then
          echo "*****Clean Build Enabled*****"
          run_command='rm -rf build devel && catkin_make && exit'
        fi

        echo "Building packages from docker file: $image_name:1.0"
        if docker run -it --rm=true \
            --privileged \
            --network host \
            ${DOCKER_ARGS[@]} \
            -e DISPLAY=$DISPLAY \
            -v $PWD/build_files:/workspaces/robo_arm_ws/ \
            -v $PWD:/workspaces/robo_arm_ws/src \
            -v /etc/localtime:/etc/localtime:ro \
            --name "$container_name" \
            --workdir /workspaces/robo_arm_ws \
            $@ \
            "$image_name":1.0 \
            bash -c "$run_command"; then

          echo "*****Build Successful, Ready for execution*****"
        else
          echo "*****Build error occurred. ./run_image.sh will not be executed*****"
        fi
      fi    
  else
      echo "*****Building a new Docker image: $image_name*****"
      docker build -f Dockerfile --no-cache -t "$image_name":1.0 .
  fi
