#!/bin/bash  

TAG_PREFIX=$1
STAGE=$2

cd $(git rev-parse --show-toplevel)/${STAGE} \
&& docker build --pull -t ericsgagnon/ide-base:${TAG_PREFIX}-${STAGE} -f Dockerfile . \
&& docker push ericsgagnon/ide-base:${TAG_PREFIX}-${STAGE} 

cd $(git rev-parse --show-toplevel)/

