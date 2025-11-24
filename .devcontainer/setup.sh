#!/bin/bash
# .devcontainer/setup.sh

set -e

echo "🚀 Installation des outils Kubernetes..."

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}✓${NC} $1"
}

step() {
    echo -e "${BLUE}==>${NC} $1"
}

# 1. Installation ArgoCD CLI
step "Installation ArgoCD CLI..."
ARGOCD_VERSION="v2.9.3"
curl -sSL -o /usr/local/bin/argocd "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"
chmod +x /usr/local/bin/argocd
log "ArgoCD CLI installé"

# 2. Vérification des outils
step "Vérification des installations..."
echo ""
echo "📦 Outils installés :"
echo "  kubectl  : $(kubectl version --client --short 2>/dev/null || echo 'version inconnue')"
echo "  helm     : $(helm version --short 2>/dev/null || echo 'version inconnue')"
echo "  minikube : $(minikube version --short 2>/dev/null || echo 'version inconnue')"
echo "  argocd   : $(argocd version --client --short 2>/dev/null || echo 'v2.9.3')"
echo "  docker   : $(docker --version 2>/dev/null || echo 'version inconnue')"
echo ""

# 3. Configuration de bash
step "Configuration du terminal..."
cat >> ~/.bashrc <<'EOF'

# Alias Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kdes='kubectl describe'
alias klogs='kubectl logs -f'

# Prompt coloré
export PS1="\[\e[32m\]k8s-dev\[\e[m\] \[\e[34m\]\w\[\e[m\] $ "

# Auto-completion
if command -v kubectl &> /dev/null; then
    source <(kubectl completion bash)
    complete -F __start_kubectl k
fi

if command -v helm &> /dev/null; then
    source <(helm completion bash)
fi
EOF

log "Terminal configuré"

# 4. Créer un dossier pour les scripts
step "Création du dossier scripts..."
mkdir -p /workspace/scripts
log "Dossier scripts créé"

echo ""
echo "🎉 Configuration terminée !"
echo ""
echo "💡 Prochaines étapes :"
echo "   1. Redémarrer le terminal (ou tapez: source ~/.bashrc)"
echo "   2. Vérifier les outils avec: kubectl version --client"
echo "   3. Dites-moi quand vous êtes prêt pour l'étape suivante ! 🚀"
echo ""
