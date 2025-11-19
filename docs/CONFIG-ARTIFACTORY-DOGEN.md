# 🏢 Configuration pour votre environnement (Artifactory Dogen)

Vous utilisez déjà **Artifactory** dans votre entreprise ! Voici comment adapter pour Camunda 8.

## 📦 Votre configuration actuelle (Backend)

```yaml
# Votre projet backend existant
apiVersion: v2
name: backend
version: 1.0.8
dependencies:
  - name: backend
    version: 1.0.8
    repository: https://repo.artifactory-dogen.group.echonet/artifactory/p-3844-helm
```

**Observations** :

- ✅ Artifactory : `repo.artifactory-dogen.group.echonet`
- ✅ Repository Helm : `p-3844-helm`
- ✅ Vous savez déjà comment ça marche !

---

## 🎯 Pour Camunda 8, même principe !

### Option 1 : Utiliser le même repository (si autorisé)

```yaml
# chart/Chart.yaml pour Camunda 8
apiVersion: v2
name: camunda8-dev
description: Camunda 8 deployment for dev environment
type: application
version: 1.0.0
appVersion: "8.6.0"

dependencies:
  - name: camunda-platform
    version: "10.3.3"
    # ✅ Même Artifactory, même repository
    repository: https://repo.artifactory-dogen.group.echonet/artifactory/p-3844-helm
```

**⚠️ Mais d'abord, vérifier si Camunda est disponible !**

### Option 2 : Utiliser un repository différent (probable)

Votre entreprise peut avoir plusieurs repositories Helm :

- `p-3844-helm` → Pour vos charts internes
- `helm-remote` → Pour les charts externes (comme Camunda)
- `helm-virtual` → Agrégation de tous les repos

```yaml
# chart/Chart.yaml pour Camunda 8
dependencies:
  - name: camunda-platform
    version: "10.3.3"
    # Exemple avec un repository différent
    repository: https://repo.artifactory-dogen.group.echonet/artifactory/helm-remote
```

---

## 🔍 Comment vérifier ?

### Étape 1 : Tester l'accès à Artifactory

```bash
# Vérifier si vous pouvez accéder à votre Artifactory
curl -I https://repo.artifactory-dogen.group.echonet/artifactory/p-3844-helm/index.yaml

# Si ça demande une authentification, utilisez vos credentials
curl -u votre-username:votre-password \
  https://repo.artifactory-dogen.group.echonet/artifactory/p-3844-helm/index.yaml
```

### Étape 2 : Chercher le chart Camunda

```bash
# Ajouter le repository Helm
helm repo add artifactory-helm \
  https://repo.artifactory-dogen.group.echonet/artifactory/p-3844-helm \
  --username votre-username \
  --password votre-password

# Mettre à jour
helm repo update

# Chercher Camunda
helm search repo camunda

# Si trouvé, vous verrez :
# NAME                                    CHART VERSION   APP VERSION
# artifactory-helm/camunda-platform       10.3.3          8.6.0
```

### Étape 3 : Lister tous les repositories disponibles

Demandez à votre équipe DevOps ou vérifiez dans l'interface Artifactory :

```
https://repo.artifactory-dogen.group.echonet/ui/repos/tree/General

Repositories possibles :
├── p-3844-helm          → Vos charts internes
├── helm-remote          → Proxy vers registries externes
├── helm-virtual         → Agrégation (local + remote)
└── ...
```

---

## 📝 Questions à poser à votre équipe DevOps

Envoyez ce message à votre équipe :

```
Bonjour,

Je travaille sur le déploiement de Camunda 8 et j'ai quelques questions
concernant notre Artifactory :

1. Le chart Helm "camunda-platform" est-il disponible dans Artifactory ?
   → Repository : p-3844-helm ou un autre ?

2. Si non, pouvez-vous configurer un proxy remote vers https://helm.camunda.io ?
   → Dans quel repository ?

3. Dois-je utiliser des credentials spécifiques pour accéder au repository ?
   → Username/Password ou Token API ?

4. Y a-t-il un repository helm-virtual qui agrège tous les charts ?

Contexte :
- Notre projet backend utilise déjà : p-3844-helm
- URL Artifactory : repo.artifactory-dogen.group.echonet
- Chart nécessaire : camunda-platform version 10.3.3

Merci !
```

---

## 🔐 Authentification Artifactory

Si votre Artifactory nécessite une authentification (probable), créez un secret :

```yaml
# argocd/artifactory-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: artifactory-helm-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: helm
  url: https://repo.artifactory-dogen.group.echonet/artifactory/p-3844-helm
  username: votre-username
  password: votre-password
  # Ou avec un token API (recommandé)
  # password: votre-api-token
```

Appliquez le secret :

```bash
kubectl apply -f argocd/artifactory-secret.yaml
```

---

## 🎯 Configuration finale recommandée

Basé sur votre structure existante, voici ce que je recommande :

### 1️⃣ Structure des fichiers

```
camunda8-deployement/
├── chart/
│   ├── Chart.yaml                   # Comme votre backend
│   ├── values-dev.yaml              # Configuration DEV
│   ├── values-int.yaml              # Configuration INT
│   └── values-prd.yaml              # Configuration PRD
│
├── argocd/
│   ├── camunda8-dev-app.yaml       # Application ArgoCD
│   └── artifactory-secret.yaml     # Credentials Artifactory
│
└── .gitlab-ci.yml                   # Pipeline (comme votre backend)
```

### 2️⃣ Chart.yaml adapté

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
    # À ADAPTER selon la réponse de votre équipe DevOps
    repository: https://repo.artifactory-dogen.group.echonet/artifactory/p-3844-helm
    # OU
    # repository: https://repo.artifactory-dogen.group.echonet/artifactory/helm-virtual
```

### 3️⃣ ArgoCD Application

```yaml
# argocd/camunda8-dev-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: camunda8-dev
  namespace: argocd
spec:
  project: default

  source:
    # VOTRE repository Git (à créer dans GitLab)
    repoURL: https://gitlab.dogen.group.echonet/votre-equipe/camunda8-deployement.git
    targetRevision: main
    path: chart

    helm:
      valueFiles:
        - values-dev.yaml

  destination:
    server: https://kubernetes.default.svc
    namespace: camunda-dev

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

---

## 🔄 Workflow dans votre environnement

```
1. Vous : Modifier chart/values-dev.yaml
   ↓
2. Vous : git push vers GitLab Dogen
   ↓
3. ArgoCD : Détecte le changement
   ↓
4. ArgoCD : Lit Chart.yaml
   ↓
5. Helm : Télécharge depuis Artifactory Dogen
   repository: repo.artifactory-dogen.group.echonet
   ↓
6. Helm : Applique votre configuration
   ↓
7. Kubernetes : Déploie Camunda 8 🎉
```

**Même workflow que votre backend ! Rien de nouveau ! 🎯**

---

## ✅ Checklist adaptée à votre environnement

- [ ] Contacter l'équipe DevOps pour vérifier si Camunda est dans Artifactory
- [ ] Obtenir le nom exact du repository Helm à utiliser
- [ ] Obtenir les credentials Artifactory (username/password ou token)
- [ ] Créer le secret ArgoCD avec les credentials
- [ ] Modifier `chart/Chart.yaml` avec le bon repository
- [ ] Créer votre repository Git dans GitLab Dogen
- [ ] Tester le déploiement en DEV

---

## 🆘 Si le chart Camunda n'est pas dans Artifactory

### Demander à l'équipe de l'ajouter

Ticket pour l'équipe DevOps :

```
Titre : Ajouter le chart Helm Camunda dans Artifactory

Description :
Nous avons besoin du chart Helm "camunda-platform" pour notre projet
d'orchestration de processus.

Configuration souhaitée :
- Créer un proxy remote vers : https://helm.camunda.io
- Repository cible : helm-remote ou helm-virtual
- Chart : camunda-platform
- Version minimale : 10.3.3

Note : Similaire à notre configuration backend actuelle
(repository: p-3844-helm)

Merci !
```

---

## 💡 Avantage : Vous connaissez déjà ce workflow !

**Votre backend** :

```yaml
dependencies:
  - name: backend
    repository: https://repo.artifactory-dogen.group.echonet/...
```

**Camunda 8** (pareil) :

```yaml
dependencies:
  - name: camunda-platform
    repository: https://repo.artifactory-dogen.group.echonet/...
```

**C'est exactement le même principe ! Vous savez déjà faire ! 🎉**

---

**Prochaine étape : Contactez votre équipe DevOps avec les questions ci-dessus ! 💪**
