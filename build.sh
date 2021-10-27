#!/bin/bash  

TAG_PREFIX=$1
STAGE=$2

root_dir=$(git rev-parse --show-toplevel)
echo "Root Directory: ${root_dir}"
stages=$(echo $(ls -d */ | sed -E "s:/::g" ))
build_tag="${TAG_PREFIX}-${STAGE}"
echo "Build Tag: ${build_tag}"
build_context="${root_dir}/${STAGE}"
echo "Build Context: ${build_context}"

echo ${build_context}

cd ${build_context} \
&& docker build --pull --no-cache=true -t ericsgagnon/ide-base:${build_tag}  -f ${build_context}/Dockerfile . 
build_exit_code=$?
cd ${root_dir}/
if [[ $build_exit_code -ne 0 ]] ; then
   echo "build failed"
   exit 1
fi

docker push ericsgagnon/ide-base:${build_tag}
push_exit_code=$?
if [[ ${push_exit_code} -ne 0 ]] ; then
  echo "push failed"
  exit 1
fi

if [[ ${STAGE} = 'final' ]] ; then
  echo "Because image is ${STAGE}, add tag ${TAG_PREFIX} to image and pushing."
  echo "docker tag ericsgagnon/ide-base:${build_tag} ericsgagnon/ide-base:${TAG_PREFIX}"
  docker tag ericsgagnon/ide-base:${build_tag} ericsgagnon/ide-base:${TAG_PREFIX}
  echo "docker push ericsgagnon/ide-base:${TAG_PREFIX}"
  docker push ericsgagnon/ide-base:${TAG_PREFIX}
  export TIME_TAG=$(date -u +%Y%m)
  echo "docker tag ericsgagnon/ide-base:${build_tag} ericsgagnon/ide-base:${TIME_TAG}"
  docker tag ericsgagnon/ide-base:${build_tag} ericsgagnon/ide-base:${TIME_TAG}
  echo "docker push ericsgagnon/ide-base:${TIME_TAG}"
  docker push ericsgagnon/ide-base:${TIME_TAG}
fi


echo "test the image by:"
echo "docker run -d -i -t --name ide --gpus all ericsgagnon/ide-base:${build_tag}"
echo "sleep 10 && docker logs ide "
echo "docker exec -i -t ide /bin/bash"
echo "# cleanup"
echo "docker rm -fv ide"



# docker build --pull -t ericsgagnon/ide-base:dev-languages -f Dockerfile .
# cd $(git rev-parse --show-toplevel)/languages && docker build --build-arg=GIT_TAG=$(git describe --tags) --pull -t ericsgagnon/ide-base:$(git describe --tags)-languages -f Dockerfile .
# docker run -i -t --rm --name ide --gpus all ericsgagnon/ide-base:$(git describe --tags)-languages /bin/bash
# docker push ericsgagnon/ide-base:$(git describe --tags)-languages
# docker run -d -i -t --name ide --gpus all ericsgagnon/ide-base:$(git describe --tags)-languages
# docker run -d -i -t --name ide --gpus all ericsgagnon/ide-base:dev-languages
# docker run --rm --name ide --gpus all ericsgagnon/ide-base:dev-languages nvidia-smi

