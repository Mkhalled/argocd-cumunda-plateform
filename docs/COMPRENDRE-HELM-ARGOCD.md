# 🎓 Comprendre Helm + ArgoCD - Explications pour débutants

## 🤔 La question : Pourquoi on ne fait pas `helm repo add` ?

Dans la documentation officielle Camunda, vous voyez :

```bash
helm repo add camunda https://helm.camunda.io
helm repo update
helm install camunda camunda/camunda-platform -n orchestration
```

**Mais dans notre projet, on ne fait pas ça !** Pourquoi ? 🧐

---

## 📦 Les 2 méthodes d'installation

### Méthode A : Installation manuelle (doc officielle)

```
┌─────────────┐
│    Vous     │
└──────┬──────┘
       │ 1. helm repo add camunda https://helm.camunda.io
       │ 2. helm install ...
       ↓
┌─────────────────┐
│   Kubernetes    │
└─────────────────┘
```

**Avantages** :

- ✅ Rapide pour tester
- ✅ Facile à comprendre

**Inconvénients** :

- ❌ Pas versionné dans Git
- ❌ Pas reproductible
- ❌ Pas de rollback facile
- ❌ Pas automatisé
- ❌ Chaque personne doit le faire manuellement

---

### Méthode B : Installation avec Helm dependencies (ce qu'on fait)

```
┌─────────────┐
│  Chart.yaml │ ← Dependencies définies
└──────┬──────┘
       │ dependencies:
       │   - name: camunda-platform
       │     repository: https://helm.camunda.io
       ↓
┌─────────────────┐
│  Helm/ArgoCD    │ ← Télécharge automatiquement
└──────┬──────────┘
       ↓
┌─────────────────┐
│   Kubernetes    │
└─────────────────┘
```

**Avantages** :

- ✅ Tout dans Git (GitOps)
- ✅ Reproductible
- ✅ Automatique
- ✅ Rollback facile
- ✅ Suivi des versions

---

## 🔍 Comment ça fonctionne en détail ?

### 1️⃣ On déclare la dépendance dans `Chart.yaml`

```yaml
# chart/Chart.yaml
apiVersion: v2
name: camunda8
version: 1.0.0

dependencies:
  - name: camunda-platform # Le nom du chart
    version: "10.3.3" # La version exacte
    repository: https://helm.camunda.io # D'où télécharger
```

**C'est comme un `package.json` en Node.js ou un `requirements.txt` en Python !**

### 2️⃣ Helm télécharge automatiquement

Quand ArgoCD (ou vous localement) déploie, Helm fait automatiquement :

```bash
# Helm fait ça en arrière-plan :
helm dependency update chart/
```

Cela télécharge le chart `camunda-platform` depuis `https://helm.camunda.io` et le place dans `chart/charts/`

### 3️⃣ Notre configuration override les valeurs par défaut

```yaml
# chart/values-dev.yaml
# Ces valeurs remplacent les valeurs par défaut du chart camunda-platform

zeebe:
  clusterSize: 1 # ⬅️ Override la valeur par défaut
  resources:
    requests:
      cpu: 500m # ⬅️ Override
```

---

## 🎯 Comparaison concrète

### Scénario : Installer Camunda 8 en DEV

#### ❌ Méthode manuelle (doc officielle)

```bash
# Sur votre machine
helm repo add camunda https://helm.camunda.io
helm repo update
helm install camunda camunda/camunda-platform \
  --namespace camunda-dev \
  --create-namespace \
  --set zeebe.clusterSize=1 \
  --set zeebe.resources.requests.cpu=500m \
  --set zeebe.resources.requests.memory=512Mi
  # ... 50 autres paramètres ...
```

**Problèmes** :

- 😰 Commande très longue et complexe
- 🤦 Si votre collègue veut faire pareil, il doit copier-coller
- 😱 Si vous voulez changer un paramètre, il faut refaire toute la commande
- 💀 Aucune trace dans Git

---

#### ✅ Méthode GitOps (ce qu'on fait)

```bash
# 1. Tout est dans Git
git clone https://votre-repo/camunda8-deployement.git
cd camunda8-deployement

# 2. ArgoCD déploie automatiquement
kubectl apply -f argocd/camunda8-dev-app.yaml

# C'est tout ! 🎉
```

**Avantages** :

- ✨ Une seule commande
- 📝 Tout est dans Git (versionné)
- 👥 Vos collègues peuvent reproduire exactement
- 🔄 Changements = juste modifier le fichier et push
- 🕐 Historique complet des changements

---

## 🧪 Test en local (optionnel)

Si vous voulez tester localement avant de pousser sur Git :

```bash
# 1. Télécharger les dépendances
cd chart/
helm dependency update

# Vous verrez :
# Downloading camunda-platform from https://helm.camunda.io
# Saving chart to charts/camunda-platform-10.3.3.tgz

# 2. Tester le rendu (dry-run)
helm template camunda8-dev . -f values-dev.yaml

# 3. Voir ce qui sera créé
helm template camunda8-dev . -f values-dev.yaml | kubectl apply --dry-run=client -f -

# 4. Installer réellement (si pas d'ArgoCD)
helm install camunda8-dev . -f values-dev.yaml -n camunda-dev --create-namespace
```

---

## 📁 Structure des fichiers après `helm dependency update`

```
chart/
├── Chart.yaml                    # ⬅️ Déclare la dépendance (VOUS le créez)
├── Chart.lock                    # ⬅️ Créé automatiquement (versions exactes)
├── charts/                       # ⬅️ Créé automatiquement lors du déploiement
│   └── camunda-platform-10.3.3.tgz  # ⬅️ Chart téléchargé automatiquement
├── values-dev.yaml               # ⬅️ VOUS le créez
├── values-int.yaml               # ⬅️ VOUS le créez
└── values-prd.yaml               # ⬅️ VOUS le créez
```

**🔴 IMPORTANT** :

- Le dossier `charts/` et `Chart.lock` sont générés **automatiquement**
- Vous devez les ajouter dans `.gitignore` (ne pas committer)
- ArgoCD/Helm les télécharge à chaque déploiement
- **Vous N'AVEZ PAS besoin de cloner le repo Camunda !**

---

## 🎓 Analogies pour mieux comprendre

### Analogie 1 : Construction d'une maison 🏠

**Méthode manuelle** :

- Vous allez acheter chaque matériau un par un
- Vous construisez vous-même
- Si quelqu'un veut la même maison, il doit tout refaire

**Méthode GitOps** :

- Vous avez un plan d'architecte (Git)
- L'entrepreneur (ArgoCD) commande les matériaux (Helm dependencies)
- L'entrepreneur construit selon le plan
- Si quelqu'un veut la même maison, il utilise le même plan

---

### Analogie 2 : Cuisine 👨‍🍳

**Méthode manuelle** :

```bash
# Vous faites :
aller_au_marché
acheter_tomates
acheter_oignons
couper_tomates
couper_oignons
faire_cuire 15min
ajouter_sel
# ... 50 étapes ...
```

**Méthode GitOps** :

```yaml
# Vous écrivez une recette (Chart.yaml + values.yaml)
recette: ratatouille
ingredients:
  - tomates: 3
  - oignons: 2
cuisson:
  durée: 15min
  température: 180°C
```

Puis le chef (ArgoCD) suit la recette automatiquement !

---

## 🔄 Workflow complet avec ArgoCD

```
1. Développeur modifie values-dev.yaml
   ↓
2. git commit + git push
   ↓
3. ArgoCD détecte le changement dans Git
   ↓
4. ArgoCD lit Chart.yaml et voit les dependencies
   ↓
5. Helm télécharge automatiquement camunda-platform depuis https://helm.camunda.io
   ↓
6. Helm merge values-dev.yaml avec les valeurs par défaut
   ↓
7. Helm génère les manifestes Kubernetes finaux
   ↓
8. ArgoCD applique sur le cluster
   ↓
9. Camunda 8 est déployé ! 🎉
```

**Vous n'avez jamais eu besoin de faire `helm repo add` manuellement !**

---

## ❓ Questions fréquentes

### Q: Est-ce que je dois installer Helm sur ma machine ?

**R:** Non, seulement si vous voulez tester localement. ArgoCD a Helm intégré.

### Q: Où est stocké le chart `camunda-platform` ?

**R:** Il est téléchargé automatiquement depuis `https://helm.camunda.io` dans le dossier `chart/charts/` (temporairement, lors du déploiement)

### Q: Est-ce que je dois cloner le repository Camunda dans mon Git ?

**R:** **NON !** Vous ne clonez RIEN. Helm télécharge automatiquement le chart depuis internet. Votre repo contient UNIQUEMENT :

- `Chart.yaml` (référence au chart Camunda)
- `values-*.yaml` (vos configurations)
- Configuration ArgoCD

### Q: Puis-je voir ce qu'il y a dans le chart Camunda officiel ?

**R:** Oui ! Si vous testez localement :

```bash
# Après helm dependency update
cd chart/charts/
tar -xzf camunda-platform-10.3.3.tgz
cd camunda-platform/
# Vous verrez tous les fichiers du chart officiel
```

Mais en production, ArgoCD fait tout ça automatiquement et vous n'avez pas besoin d'y toucher.

### Q: Comment savoir quelle version du chart utiliser ?

**R:** Allez sur https://github.com/camunda/camunda-platform-helm/releases

### Q: Puis-je mixer méthode manuelle et ArgoCD ?

**R:** Techniquement oui, mais **ne le faites pas** ! Choisissez une méthode et tenez-vous-y. ArgoCD est la méthode recommandée en entreprise.

---

## 🎯 Résumé en 3 points

1. **Doc officielle** = Installation manuelle avec `helm repo add` (pour tester rapidement)

2. **Notre méthode** = Dependencies dans `Chart.yaml` (pour production, GitOps)

3. **ArgoCD** = Gère tout automatiquement, vous n'avez qu'à modifier les fichiers YAML et pousser sur Git

---

## 🚀 Pour aller plus loin

### Commandes utiles

```bash
# Voir les repos Helm sur votre machine (si vous testez localement)
helm repo list

# Chercher des charts disponibles
helm search repo camunda

# Voir les versions disponibles
helm search repo camunda-platform --versions

# Voir les valeurs par défaut d'un chart
helm show values camunda/camunda-platform

# Comparer avec nos valeurs
diff <(helm show values camunda/camunda-platform) chart/values-dev.yaml
```

### Documentation

- [Helm Dependencies](https://helm.sh/docs/helm/helm_dependency/)
- [ArgoCD + Helm](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/)
- [GitOps Principles](https://www.gitops.tech/)

---

**Maintenant vous comprenez pourquoi on ne fait pas `helm repo add` ! 🎓**
