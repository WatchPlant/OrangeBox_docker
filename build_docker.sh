#!/bin/bash


IMAGE_NAME=orange_box_img
IMAGE_TAG=latest

export DOCKER_BUILDKIT=1
docker build \
  --ssh default \
  --no-cache \
  -t $IMAGE_NAME:$IMAGE_TAG \
  -f Dockerfile .

