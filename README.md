# Arch Linux in Docker for daily use

This is for when you want to use Arch Linux in Docker as an end user, for daily tasks such as using the internet, writing code etc.

Most use cases for Arch in Docker, indeed for Docker itself, are actually instead just for _single_ applications, like running a Postgres process as part of a Docker Swarm or Kubernetes setup for example.

So for a more user-oriented daily-use approach, the config is relatively unknown and not-well documented. Hence this repo as an attempt to change that.

I ([@tombh](https://github.com/tombh)) personally use this for running Arch Linux on a remote Digital Ocean VPS. Not only is it useful because Digital Ocean no longer natively supports Arch Linux, but it's also useful for when I want to migrate the entire OS to another machine: I just copy the Docker image.

## Quick start

Just running `start.sh` will start an Arch container in the background. You can then attach to it with something like `docker exec -it <ID> bash`, where `<ID>` is the ID of the container you just created (see `docker ps -a`).

## Committing changes

The big difference with running a daily OS in Docker is that _all changes are lost when the container is deleted_. Just restarting the container is ok, say when the host reboots. But if you want to change any of the arguments in `start.sh` then you'll most often need to kill the running container and recreate it from scratch.

You can do that and keep all your OS's current filesystem just by using `docker commit`:

  1. It's always best to first `docker stop <ID>` (this is safe).
  2. Then `docker commit <ID> <image name>`. `<image name>` could be the name of the original Arch Linux image (archlinux/archlinux), but you may want to keep that in order to make other starter containers. Instead, why not name the new image something like "my-arch-os" etc. This step can take a long time if there have been lots of changes.
  3. With the new image you can now recreate the container with something like `IMAGE_NAME=my-arch-os start.sh`

Note that recreating the container like this is also basically the only way to "reboot" the OS in the container. Which is relevant if you've made changes, like installing or updating a package that "requires reboot".

## Contributions

I'm currently the only user of this. And there doesn't seem to be many others documenting that they're doing something similar. So please let me know if you find this useful, or have any tweaks, or just have any questions ❤
