set -ex
# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=sdal
# image name
IMAGE=${PWD##*/}
docker build --rm -t $USERNAME/$IMAGE:latest .
