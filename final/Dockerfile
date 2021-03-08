ARG VERSION=dev

FROM ericsgagnon/ide-base:${VERSION}-languages as base

# this may not be necessary but may give insight on source files
ENV WORKSPACE="/tmp/workspace/final"
COPY . ${WORKSPACE}/

# final stage is intended to provide a consistent build pattern, even if nothing 
# significant is done here. 

# user utilities 

# docker cli ##############################################
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" \
    && apt-get update && apt-get install -y \
    docker-ce-cli

# github cli ###################################################
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 \
    && apt-add-repository https://cli.github.com/packages \
    && apt-get update \
    && apt-get install -y gh

# helm ####################################################
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -

# kubectl & kubeadm #######################################
# install latest stable release
RUN cd /tmp \
    && curl -L --remote-name-all "https://storage.googleapis.com/kubernetes-release/release/$(curl -sSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/{kubeadm,kubectl}" \
    && install -m 0755 kubeadm /usr/local/bin \
    && install -m 0755 kubectl /usr/local/bin \
    && rm ./kubeadm  ./kubectl

# argo workflows ##############################################
RUN cd /tmp \
    && VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-workflows/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/') \
    && curl -sSL -o argo.gz "https://github.com/argoproj/argo-workflows/releases/download/"$VERSION"/argo-linux-amd64.gz" \
    && gunzip argo.gz \
    && mv argo /usr/local/bin/argo \
    && chmod +x /usr/local/bin/argo

# argocd ###################################################
RUN VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/') \
    && curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64 \
    && chmod +x /usr/local/bin/argocd

# tekton #####################################################
# https://tekton.dev/docs/cli/
RUN VERSION=$(curl --silent "https://api.github.com/repos/tektoncd/cli/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/') \
    && curl -sSL -o tkn.tar.gz "https://github.com/tektoncd/cli/releases/download/v"$VERSION"/tkn_"$VERSION"_Linux_x86_64.tar.gz" \
    && tar xvzf tkn.tar.gz -C /usr/local/bin tkn \
    && chmod +x /usr/local/bin/tkn \
    && rm tkn.tar.gz

# sourcegraph cli #############################################
# https://github.com/sourcegraph/src-cli

RUN curl -L https://sourcegraph.com/.api/src-cli/src_linux_amd64 -o /usr/local/bin/src \
    && chmod +x /usr/local/bin/src
