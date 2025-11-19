#!/bin/bash

# 🔍 Script de diagnostic réseau pour Camunda 8
# Ce script teste la connectivité aux différents registries

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Diagnostic réseau - Camunda 8"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test fonction
test_connectivity() {
    local url=$1
    local name=$2
    
    echo -n "Testing $name... "
    
    if curl -s -I --connect-timeout 5 "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

echo "📡 Test 1: Accès au registry Helm Camunda officiel"
echo "─────────────────────────────────────────────────"
test_connectivity "https://helm.camunda.io/index.yaml" "Helm Camunda"
echo ""

echo "📡 Test 2: Accès au registry Docker officiel"
echo "─────────────────────────────────────────────────"
test_connectivity "https://registry.camunda.cloud" "Camunda Registry"
test_connectivity "https://registry-1.docker.io/v2/" "Docker Hub"
echo ""

echo "📡 Test 3: Test depuis le cluster Kubernetes"
echo "─────────────────────────────────────────────────"
echo "Création d'un pod de test..."

# Créer un pod temporaire pour tester depuis le cluster
kubectl run network-test --rm -i --restart=Never --image=alpine:latest -- sh -c "
    apk add --no-cache curl > /dev/null 2>&1
    echo -n 'Test depuis le cluster: '
    if curl -s -I --connect-timeout 5 https://helm.camunda.io/index.yaml > /dev/null 2>&1; then
        echo '✅ Accès Internet OK'
        exit 0
    else
        echo '❌ Pas d accès Internet'
        exit 1
    fi
" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Le cluster a accès à Internet${NC}"
else
    echo -e "${RED}Le cluster N'A PAS accès à Internet${NC}"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Résumé et Recommandations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Détection de proxy
if [ ! -z "$HTTP_PROXY" ] || [ ! -z "$HTTPS_PROXY" ]; then
    echo -e "${YELLOW}⚠️  Proxy HTTP détecté:${NC}"
    echo "   HTTP_PROXY: $HTTP_PROXY"
    echo "   HTTPS_PROXY: $HTTPS_PROXY"
    echo ""
fi

echo "💡 Solutions possibles:"
echo ""
echo "1️⃣  Si ✅ OK depuis votre poste mais ❌ FAILED depuis le cluster:"
echo "    → Le cluster a un accès réseau restreint"
echo "    → Utilisez un registry interne (Artifactory, Harbor, Nexus)"
echo "    → Ou demandez une exception firewall"
echo ""
echo "2️⃣  Si ❌ FAILED partout:"
echo "    → Votre réseau bloque l'accès"
echo "    → Contactez votre équipe réseau/sécurité"
echo "    → Utilisez obligatoirement un registry interne"
echo ""
echo "3️⃣  Si ✅ OK partout:"
echo "    → Vous pouvez utiliser https://helm.camunda.io directement"
echo "    → Aucun changement nécessaire dans Chart.yaml"
echo ""

echo "📖 Pour plus d'informations:"
echo "   → docs/ACCES-RESEAU-RESTREINT.md"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
