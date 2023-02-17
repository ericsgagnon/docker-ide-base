ARG VERSION=dev

# docker build --pull --no-cache=true -t trash  -f Dockerfile . 

FROM ericsgagnon/ide-base:${VERSION}-languages as base

# this may not be necessary but may give insight on source files
ENV WORKSPACE=/tmp/workspace/ide-base/final
COPY . ${WORKSPACE}/

# user utilities 
RUN apt-get update && apt-get install -y \
    graphviz \
    gsfonts \
    graphviz-doc \
    fonts-liberation \
    libann0 \
    libcdt5 \
    libcgraph6 \
    libgts-0.7-5 \
    libgts-bin \
    libgvc6 \
    libgvpr2 \
    liblab-gamut1 \
    libpathplan4  \
    inotify-tools \
    libinotifytools0 \
    libinotifytools0-dev


COPY --from=docker           /usr/local/bin/docker      /usr/local/bin/docker
COPY --from=argoproj/argocli /bin/argo                  /usr/local/bin/argo
COPY --from=argoproj/argocd  /usr/local/bin/argocd      /usr/local/bin/argocd

# bazel ###################################################
RUN wget -O /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.14.0/bazelisk-linux-amd64 \
    && chmod +x /usr/local/bin/bazel

# github cli ###################################################
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y

# watchman #################################################
RUN cd /tmp \
    && wget -O watchman.zip https://github.com/facebook/watchman/releases/download/v2022.10.10.00/watchman-v2022.10.10.00-linux.zip \
    && unzip watchman.zip \
    && mv watchman-* watchman \
    && chmod -R 755 watchman/bin \
    && cp watchman/bin/* /usr/local/bin/ \
    && cp watchman/lib/* /usr/local/lib/ \
    && rm -rf /tmp/watchman \
    && rm /tmp/watchman.zip \    
    && mkdir -p /usr/local/var/run/watchman \
    && chmod -R 2777 /usr/local/var/run/watchman \
    && wget -O libssl1.1.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.17_amd64.deb \
    && dpkg -i libssl1.1.deb \
    && rm libssl1.1.deb

# rclone ###################################################
RUN curl https://rclone.org/install.sh | bash

# minio-mc #################################################
RUN wget -O /usr/bin/mc \
    https://dl.min.io/client/mc/release/linux-amd64/mc \
    && chmod +x /usr/bin/mc

# helm ####################################################
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -

# tekton #####################################################
# https://tekton.dev/docs/cli/
RUN gpg --recv-keys --keyserver keyserver.ubuntu.com 3EFE0E0A2F2F60AA \
    && gpg --export 3EFE0E0A2F2F60AA | sudo tee /etc/apt/trusted.gpg.d/tektoncd.gpg \
    && echo "deb http://ppa.launchpad.net/tektoncd/cli/ubuntu jammy main" | tee /etc/apt/sources.list.d/tektoncd-ubuntu-cli.list \
    && apt-get update && apt-get install -y tektoncd-cli 

# sourcegraph cli #############################################
# https://github.com/sourcegraph/src-cli
RUN curl -L https://sourcegraph.com/.api/src-cli/src_linux_amd64 -o /usr/local/bin/src \
    && chmod +x /usr/local/bin/src

# yq ##########################################################
RUN wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.28.1/yq_linux_amd64 \
    && chmod +x /usr/local/bin/yq

# kubectl & kubeadm #######################################
# install latest stable release
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update && apt-get install -y kubeadm kubectl

