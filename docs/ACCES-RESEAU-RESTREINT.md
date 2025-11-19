# 🔒 Solutions pour entreprises avec accès Internet restreint

## 🚨 Le problème

Votre entreprise bloque l'accès à `https://helm.camunda.io` depuis le cluster Kubernetes.

```yaml
# Chart.yaml
dependencies:
  - name: camunda-platform
    repository: https://helm.camunda.io # ❌ Bloqué par le proxy/firewall
```

**Erreur typique** :

```
Error: failed to download "camunda-platform"
dial tcp: lookup helm.camunda.io: no such host
```

---

## ✅ Solution 1 : Utiliser le registry Helm interne (RECOMMANDÉ)

La plupart des entreprises ont un **registry Helm privé** (Harbor, Artifactory, Nexus, etc.)

### Étape 1 : Demander à votre équipe DevOps

Posez ces questions à votre équipe :

- "Avons-nous un registry Helm interne ?"
- "Est-ce que le chart Camunda est déjà mirroré ?"
- "Quelle est l'URL du registry ?"

### Étape 2 : Utiliser le registry interne

```yaml
# Chart.yaml - Utiliser le registry interne
apiVersion: v2
name: camunda8-dev
description: Camunda 8 deployment for dev environment
type: application
version: 1.0.0
appVersion: "8.6.0"

dependencies:
  - name: camunda-platform
    version: "10.3.3"
    # ✅ Registry interne au lieu d'Internet
    repository: https://artifactory.votre-entreprise.com/helm-virtual
    # ou
    # repository: https://harbor.votre-entreprise.com/chartrepo/camunda
```

### Étape 3 : Authentification (si nécessaire)

Si le registry nécessite une authentification :

```bash
# Créer un secret Kubernetes avec les credentials
kubectl create secret docker-registry helm-registry-secret \
  --docker-server=artifactory.votre-entreprise.com \
  --docker-username=votre-username \
  --docker-password=votre-password \
  --namespace=camunda-dev
```

Puis dans ArgoCD :

```yaml
# argocd/camunda8-dev-app.yaml
spec:
  source:
    helm:
      valueFiles:
        - values-dev.yaml
      # Ajouter les credentials pour le registry privé
      parameters:
        - name: global.image.pullSecrets[0]
          value: helm-registry-secret
```

---

## ✅ Solution 2 : Demander une exception au firewall

Si votre entreprise n'a pas de registry interne, demandez à votre équipe sécurité d'autoriser :

### Domaines à whitelister

```
# Helm repository
helm.camunda.io

# Images Docker (utilisées par le chart)
registry.camunda.cloud
docker.io
```

### Template de demande d'exception

```
Objet : Demande d'autorisation d'accès - Déploiement Camunda 8

Bonjour équipe Sécurité,

Nous souhaitons déployer Camunda 8 sur notre cluster Kubernetes pour
l'orchestration de processus métier.

Domaines requis :
- helm.camunda.io (port 443) - Repository Helm charts
- registry.camunda.cloud (port 443) - Images Docker
- docker.io (port 443) - Images Docker (fallback)

Justification : Camunda 8 est une solution d'orchestration entreprise.
Le chart Helm et les images sont maintenus officiellement par Camunda.

Environnements : DEV, INT, PRD
Fréquence d'accès : Lors des déploiements uniquement

Merci,
[Votre nom]
```

---

## ✅ Solution 3 : Télécharger et héberger localement (MANUEL)

Si aucune des options ci-dessus n'est possible, vous pouvez héberger le chart vous-même.

### Étape 1 : Télécharger le chart (depuis un poste avec Internet)

```bash
# Sur une machine avec accès Internet
helm repo add camunda https://helm.camunda.io
helm repo update

# Télécharger le chart
helm pull camunda/camunda-platform --version 10.3.3

# Vous obtenez : camunda-platform-10.3.3.tgz
```

### Étape 2 : Héberger dans votre Git (Option A - Simple mais pas idéal)

```bash
# Créer un dossier pour les charts
mkdir -p charts/

# Décompresser le chart
tar -xzf camunda-platform-10.3.3.tgz -C charts/

# Structure
charts/
└── camunda-platform/
    ├── Chart.yaml
    ├── values.yaml
    ├── templates/
    └── ...
```

Modifier `Chart.yaml` pour référencer le chart local :

```yaml
# Chart.yaml - Référence locale
apiVersion: v2
name: camunda8-dev
description: Camunda 8 deployment for dev environment
type: application
version: 1.0.0
appVersion: "8.6.0"

dependencies:
  - name: camunda-platform
    version: "10.3.3"
    repository: "file://./charts/camunda-platform" # ✅ Référence locale
```

**⚠️ Inconvénients** :

- Vous devez committer tout le code source (plusieurs Mo)
- Difficile à maintenir et mettre à jour
- Non recommandé en production

### Étape 3 : Héberger sur un serveur HTTP interne (Option B - Mieux)

Si vous avez un serveur web interne :

```bash
# 1. Créer un index Helm
helm repo index . --url https://votre-serveur-interne.com/helm-charts

# 2. Upload le .tgz et index.yaml sur le serveur
scp camunda-platform-10.3.3.tgz serveur:/var/www/helm-charts/
scp index.yaml serveur:/var/www/helm-charts/
```

Modifier `Chart.yaml` :

```yaml
dependencies:
  - name: camunda-platform
    version: "10.3.3"
    repository: https://votre-serveur-interne.com/helm-charts
```

---

## ✅ Solution 4 : Utiliser un proxy HTTP

Si votre entreprise a un proxy HTTP pour Internet :

### Configurer Helm pour utiliser le proxy

```bash
# Variables d'environnement
export HTTP_PROXY="http://proxy.votre-entreprise.com:8080"
export HTTPS_PROXY="http://proxy.votre-entreprise.com:8080"
export NO_PROXY="localhost,127.0.0.1,.votre-entreprise.com"
```

### Configurer ArgoCD pour utiliser le proxy

Ajouter dans la configuration ArgoCD :

```yaml
# Dans le ConfigMap argocd-cm
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  repository.credentials: |
    - url: https://helm.camunda.io
      proxy: http://proxy.votre-entreprise.com:8080
```

---

## 🎯 Quelle solution choisir ?

### Pour un environnement d'entreprise sécurisé :

```
1️⃣ Registry interne (Harbor/Artifactory)     ⭐⭐⭐⭐⭐ RECOMMANDÉ
   ✅ Contrôle total
   ✅ Conforme aux politiques de sécurité
   ✅ Performances optimales
   ✅ Cache local

2️⃣ Demande d'exception firewall             ⭐⭐⭐⭐
   ✅ Simple à mettre en place
   ✅ Mises à jour faciles
   ⚠️ Nécessite approbation sécurité

3️⃣ Proxy HTTP                               ⭐⭐⭐
   ✅ Rapide si déjà configuré
   ⚠️ Dépend de la config proxy

4️⃣ Hébergement manuel local                 ⭐⭐
   ⚠️ Difficile à maintenir
   ⚠️ Gros fichiers dans Git
   ❌ Non recommandé pour production
```

---

## 📝 Template Chart.yaml selon votre solution

### Option 1 : Registry interne (Artifactory)

```yaml
apiVersion: v2
name: camunda8-dev
description: Camunda 8 deployment for dev environment
type: application
version: 1.0.0
appVersion: "8.6.0"

dependencies:
  - name: camunda-platform
    version: "10.3.3"
    repository: https://artifactory.votre-entreprise.com/helm-virtual
```

### Option 2 : Registry interne (Harbor)

```yaml
apiVersion: v2
name: camunda8-dev
description: Camunda 8 deployment for dev environment
type: application
version: 1.0.0
appVersion: "8.6.0"

dependencies:
  - name: camunda-platform
    version: "10.3.3"
    repository: https://harbor.votre-entreprise.com/chartrepo/public
```

### Option 3 : Serveur HTTP interne

```yaml
apiVersion: v2
name: camunda8-dev
description: Camunda 8 deployment for dev environment
type: application
version: 1.0.0
appVersion: "8.6.0"

dependencies:
  - name: camunda-platform
    version: "10.3.3"
    repository: https://helm-charts.votre-entreprise.com
```

### Option 4 : Chart local (dernier recours)

```yaml
apiVersion: v2
name: camunda8-dev
description: Camunda 8 deployment for dev environment
type: application
version: 1.0.0
appVersion: "8.6.0"

dependencies:
  - name: camunda-platform
    version: "10.3.3"
    repository: file://./charts/camunda-platform
```

---

## 🔍 Comment tester la connexion ?

### Depuis votre poste

```bash
# Tester l'accès au registry
curl -I https://helm.camunda.io/index.yaml

# Si ça fonctionne, vous verrez :
# HTTP/2 200
# content-type: application/x-yaml

# Si ça échoue :
# curl: (6) Could not resolve host: helm.camunda.io
```

### Depuis le cluster Kubernetes

```bash
# Créer un pod de test
kubectl run -it --rm debug --image=alpine --restart=Never -- sh

# Dans le pod
apk add curl
curl -I https://helm.camunda.io/index.yaml

# Si ça échoue, vous avez un problème réseau
```

---

## 🆘 Checklist de dépannage

Si le déploiement échoue à cause de l'accès réseau :

- [ ] Vérifier l'accès à `helm.camunda.io` depuis votre poste
- [ ] Vérifier l'accès depuis un pod dans le cluster
- [ ] Contacter votre équipe réseau/sécurité
- [ ] Demander l'URL du registry Helm interne
- [ ] Vérifier si un proxy HTTP est requis
- [ ] Tester avec `curl` depuis le cluster
- [ ] Consulter les logs ArgoCD : `kubectl logs -n argocd <argocd-pod>`

---

## 📞 Questions à poser à votre équipe DevOps

```
1. "Avons-nous un registry Helm privé (Harbor, Artifactory, Nexus) ?"
   → URL : _____________________

2. "Le chart Camunda est-il déjà disponible dans le registry ?"
   → Oui / Non

3. "Si non, puis-je demander qu'il soit mirroré ?"
   → Contact : _____________________

4. "Faut-il des credentials pour accéder au registry ?"
   → Username : _____________________
   → Secret : _____________________

5. "Y a-t-il un proxy HTTP à configurer ?"
   → Proxy : _____________________

6. "Puis-je demander une exception firewall pour helm.camunda.io ?"
   → Contact sécurité : _____________________
```

---

## ✅ Prochaines étapes

1. **Contactez votre équipe DevOps** avec les questions ci-dessus
2. **Choisissez la solution** adaptée à votre organisation
3. **Modifiez** `Chart.yaml` selon la solution choisie
4. **Testez** le déploiement
5. **Documentez** la solution dans votre README

---

**Besoin d'aide pour configurer une solution spécifique ? Dites-moi laquelle ! 💪**
