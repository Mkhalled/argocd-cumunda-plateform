FROM ubuntu:22.04

# Éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive

# Versions des outils
ARG KUBECTL_VERSION=1.28.0
ARG HELM_VERSION=3.13.0
ARG MINIKUBE_VERSION=1.32.0
ARG ARGOCD_VERSION=2.9.3

# Installation des dépendances de base
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    jq \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    bash-completion \
    conntrack \
    socat \
    && rm -rf /var/lib/apt/lists/*

# Installation de Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Installation de kubectl
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/ \
    && kubectl completion bash > /etc/bash_completion.d/kubectl

# Installation de Helm
RUN curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar xz \
    && mv linux-amd64/helm /usr/local/bin/ \
    && rm -rf linux-amd64 \
    && helm completion bash > /etc/bash_completion.d/helm

# Installation de Minikube
RUN curl -Lo /usr/local/bin/minikube "https://storage.googleapis.com/minikube/releases/v${MINIKUBE_VERSION}/minikube-linux-amd64" \
    && chmod +x /usr/local/bin/minikube

# Installation de ArgoCD CLI
RUN curl -sSL -o /usr/local/bin/argocd "https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64" \
    && chmod +x /usr/local/bin/argocd

# Configuration de bash avec des alias utiles
RUN echo 'alias k=kubectl' >> /root/.bashrc \
    && echo 'alias h=helm' >> /root/.bashrc \
    && echo 'alias kgp="kubectl get pods"' >> /root/.bashrc \
    && echo 'alias kgs="kubectl get svc"' >> /root/.bashrc \
    && echo 'alias kgn="kubectl get nodes"' >> /root/.bashrc \
    && echo 'alias kdes="kubectl describe"' >> /root/.bashrc \
    && echo 'alias klogs="kubectl logs -f"' >> /root/.bashrc \
    && echo 'export PS1="\[\e[32m\]k8s-dev\[\e[m\] \[\e[34m\]\w\[\e[m\] $ "' >> /root/.bashrc \
    && echo 'source /etc/bash_completion' >> /root/.bashrc

# Créer les répertoires nécessaires
RUN mkdir -p /workspace /root/.kube /root/.minikube

# Rétablir le frontend interactif
ENV DEBIAN_FRONTEND=dialog

WORKDIR /workspace

# Commande par défaut
CMD ["/bin/bash"]
