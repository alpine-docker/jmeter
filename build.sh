#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in CI
# DOCKER_USERNAME
# DOCKER_PASSWORD

set -e

# usage
Usage() {
  echo "$0 <image_name>"
}

if [ $# -eq 0 ]; then
  Usage
  exit 1
fi

image="alpine/$1"
platform="${2:-linux/arm/v7,linux/arm64/v8,linux/arm/v6,linux/amd64,linux/ppc64le,linux/s390x}"

curl -H "Cache-Control: no-cache" -sL "https://raw.githubusercontent.com/alpine-docker/multi-arch-libs/stable/functions.sh" -o functions.sh
source functions.sh

# tag for reference: rel/v5.6.3
tag=$(get_latest_release apache/jmeter)
tag=${tag#rel/v}
echo $tag

build_arg="JMETER_VERSION=${tag}"

echo "Building image for tag: ${tag}"
build_docker_image "${tag}" "${image}" "${platform}" "${build_arg}"
