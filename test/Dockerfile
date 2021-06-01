
FROM ericsgagnon/buildpack-deps-cuda:cuda11.2-ubuntu20.04 as base

# environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LANG=en_US.UTF-8
#ENV LC_ALL=en_US.UTF-8
ENV SHELL=/bin/bash
ENV WORKSPACE=/tmp/workspace/ide-base/base
ENV CUDA_HOME=/usr/local/cuda

# this may not be necessary but may give insight on source files
COPY . ${WORKSPACE}/

RUN chsh -s /bin/bash

##################################################################################################################

# install os libraries, utilities, etc. - some of these are already installed in buildpack-deps
# RUN apt update -y && apt upgrade -y && \
#     apt install -y --no-install-recommends \
#     aptitude \
#     man 

ENV PAGER=less

# nss wrapper lets us mount passwd and group files if necessary
#ENV LD_PRELOAD=/usr/lib/libnss_wrapper.so:${LD_PRELOAD}
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:${LD_LIBRARY_PATH}
ENV NSS_WRAPPER_PASSWD=/etc/passwd
ENV NSS_WRAPPER_GROUP=/etc/group

# user home directories ####################################################
ENV ENV_FILE=/etc/profile.d/0000-env.sh
RUN mkdir -p \
    /etc/skel/.local/bin   \
    /etc/skel/.local/share \
    /etc/skel/.config      \
    /etc/skel/.cache       \
    && echo "source ${ENV_FILE}"    >> /etc/skel/.bashrc \
    && cat ${WORKSPACE}/bashrc.stub >> /etc/skel/.bashrc

# profile ##################################################################
COPY skel-rsync.sh  /etc/profile.d/
#COPY 0000-env.sh    /etc/profile.d/

# RUN echo "# ${WORKSPACE}/Dockerfile's ENV Directives (single line directives only):" >> /etc/profile.d/0000-env.sh \
#     && cat ${WORKSPACE}/Dockerfile | \
#     grep -E "^ENV" | \
#     sed -E "s/^ENV ([^=]+)/export \1/g" | \
#     sort | \
#     uniq | \
#     envsubst >> \
#     /etc/profile.d/0000-env.sh  \
#     && echo "#############################################################" >> /etc/profile.d/0000-env.sh

# s6 process manager ######################################################
ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-ove rlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer /


COPY 000-env.sh               /etc/cont-init.d/
COPY 001-userconf.sh          /etc/cont-init.d/
COPY s6-nvidia-check.sh       /etc/cont-init.d/

#RUN /bin/bash ${WORKSPACE}/env-propagator.sh

ENTRYPOINT [ "/init" ]

# use bash as default cmd
CMD [ "/bin/bash" ]
