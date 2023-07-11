#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

# set -ex

build() {

  echo "Found new version, building the image ${image}:${tag}"
  echo docker build --no-cache --build-arg JMETER_VERSION=${tag} -t ${image}:${tag} .
  docker build --no-cache --build-arg JMETER_VERSION=${tag} -t ${image}:${tag} .

  # # run test
  # version=$(docker run -ti --rm ${image}:${tag} --version|grep ${tag}|awk '{print $NF}')
  # if [ "${version}" == "${tag}" ]; then
  #   echo "matched"
  # else
  #   echo "unmatched"
  #   exit
  # fi

  if [[ "$TRAVIS_BRANCH" == "master" && "$TRAVIS_PULL_REQUEST" == false ]]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker push ${image}:${tag}
  fi
}

image="alpine/jmeter"
repo="apache/jmeter"

latest=$(curl -sL https://archive.apache.org/dist/jmeter/binaries/ |grep -oP '(?<=href=\")[^"]*'|grep tgz$ |cut -d \- -f3|sed 's/\.tgz//' |sort -rn |head -10)

for tag in ${latest}
do
  echo $tag
  status=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${tag})
  echo $status
  if [[ "${status}" =~ "not found" ]]; then
    build
  fi
done

echo "Update latest image with latest release"
latest=$(echo $latest |xargs -n1|sort -Vr|head -1)
echo $latest

if [[ "$CIRCLE_BRANCH" == "master" && "$CIRCLE_PULL_REQUEST" == false ]]; then
  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
  docker pull ${image}:${latest}
  docker tag ${image}:${latest} ${image}:latest
  docker push ${image}:latest
fi
