#!/usr/bin/env bash

# See README.md in this repo for usage instructions

IMAGE_NAME=${IMAGE_NAME:=archlinux/archlinux}
EXTERNAL_MOUNT=${EXTERNAL_MOUNT:=/mnt/arch_in_docker}
INTERNAL_MOUNT=${INTERNAL_MOUNT:=/mnt/host_accessible}

# Writing the command and arguments in () allows us to use comments.
start=(
  docker run

  # Run container in the background and return to the shell immediately.
  --detach
  # Restart the container when the host machine reboots.
  --restart=always

  # Allow connecting via `docker exec -it bash`
  # TODO:
  #   Does this have downsides applying these all the time if you only ever actually want
  #   to just connect via SSH for example?
  --interactive
  --tty

  # Use the host's network; devices, ports etc:
  # Mainly this means you don't have to keep stopping and starting the container to open/close
  # ports.
  --network=host

  # Enabling Docker in Docker:
  # The simplest way to do this is just to connect to the host's Docker server. However, this
  # has one significant drawback, you can't easily mount paths because the Docker server
  # treats all paths as referring to the host filesystem.
  --volume /var/run/docker.sock:/var/run/docker.sock
  # To get around the Docker host pathing problem, we can mount a particular host path into
  # the guest Arch container. Let's say:
  #   EXTERNAL_MOUNT=/mnt/arch_in_docker
  #   INTERNAL_MOUNT=/mnt/host_accessible
  # You can then do something like (all inside the running Arch container):
  #   `echo "hello" > /mnt/host_accessible/file.txt`
  #   `docker run -v /mnt/arch_in_docker/file.txt:/file.txt bash cat /file.txt`
  # Which should output: hello
  --volume $EXTERNAL_MOUNT:$INTERNAL_MOUNT

  # TMPFS setup:
  # The tmp filesystem is in-memory and so faster, but more importantly can reduce wear on
  # SSDs for frequent read/writes.
  --tmpfs /run
  --tmpfs /run/lock
  # Regarding `:exec` Some Pacman/AUR builds need to execute binaries built in /tmp
  --tmpfs /tmp:exec

  # Give the container permissions to use privileged kernel features:
  # TODO: give examples of what these enable
  --cap-add=all
  --privileged

  # CGroup-specific options (needed since systemd ~v248):
  --security-opt seccomp=unconfined
  --cgroup-parent=docker.slice
  --cgroupns private

  $IMAGE_NAME
)

# Execute the command, ignoring comments:
"${start[@]}"
