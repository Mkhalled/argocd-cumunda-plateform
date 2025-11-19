# ❓ FAQ - Questions fréquentes débutants

## 🤔 Est-ce que je dois cloner Camunda dans mon repository ?

### ❌ NON !

Vous **N'AVEZ PAS** à :

- Cloner le repository GitHub de Camunda
- Copier les fichiers sources de Camunda
- Télécharger manuellement le chart Helm
- Maintenir une copie du code Camunda

### ✅ Ce que vous devez faire

Créer **uniquement** ces fichiers dans votre repository Git :

```
votre-repo/
├── chart/
│   ├── Chart.yaml          ← Référence à Camunda (juste l'URL !)
│   └── values-dev.yaml     ← Votre configuration
│
└── argocd/
    └── camunda8-dev-app.yaml  ← Configuration ArgoCD
```

**Taille totale : < 10 Ko** (quelques fichiers YAML)

---

## 🎯 Pourquoi c'est confusant ?

### Dans d'autres situations, vous clonez des repos

Quand vous développez une application normale :

```bash
# Vous clonez VOTRE code
git clone https://github.com/votre-entreprise/votre-app.git
```

### Mais avec Helm, c'est différent !

Helm utilise un **système de packages** comme npm ou pip :

```yaml
# Chart.yaml - C'est comme un package.json
dependencies:
  - name: camunda-platform
    repository: https://helm.camunda.io  ← Juste une URL !
```

Helm télécharge automatiquement depuis cette URL.

---

## 📦 Comparaison avec d'autres langages

### Node.js - Vous comprenez déjà le concept !

```json
// package.json
{
  "dependencies": {
    "express": "^4.18.0"
  }
}
```

**Est-ce que vous clonez le repo d'Express ?** NON !  
Vous faites `npm install` et npm télécharge automatiquement.

### Python

```txt
# requirements.txt
flask==3.0.0
```

**Est-ce que vous clonez le repo de Flask ?** NON !  
Vous faites `pip install` et pip télécharge automatiquement.

### Helm (même principe !)

```yaml
# Chart.yaml
dependencies:
  - name: camunda-platform
    version: "10.3.3"
    repository: https://helm.camunda.io
```

**Est-ce que vous clonez le repo de Camunda ?** NON !  
Helm fait `helm dependency update` et télécharge automatiquement.

---

## 🔄 Workflow complet

### 1️⃣ Vous créez votre repository

```bash
mkdir camunda8-deployement
cd camunda8-deployement
git init
```

### 2️⃣ Vous créez les fichiers de configuration

```bash
# Créer les fichiers
chart/Chart.yaml         ← Vous écrivez ce fichier
chart/values-dev.yaml    ← Vous écrivez ce fichier
argocd/camunda8-dev-app.yaml  ← Vous écrivez ce fichier
```

### 3️⃣ Vous committez UNIQUEMENT vos fichiers

```bash
git add chart/Chart.yaml
git add chart/values-dev.yaml
git add argocd/
git commit -m "Configuration Camunda 8"
git push
```

**Vous ne committez PAS le code source de Camunda !**

### 4️⃣ ArgoCD déploie

```bash
kubectl apply -f argocd/camunda8-dev-app.yaml
```

ArgoCD va :

1. ✅ Lire votre `Chart.yaml`
2. ✅ Voir la dépendance vers `https://helm.camunda.io`
3. ✅ Télécharger automatiquement le chart Camunda
4. ✅ Appliquer votre `values-dev.yaml`
5. ✅ Déployer sur Kubernetes

**Tout est automatique !**

---

## 🗂️ Qu'est-ce qui est dans Git vs téléchargé ?

### ✅ Dans votre Git (vous le créez)

```
camunda8-deployement/
├── chart/
│   ├── Chart.yaml          # Fichier texte de 10 lignes
│   ├── values-dev.yaml     # Fichier texte de ~100 lignes
│   ├── values-int.yaml
│   └── values-prd.yaml
│
├── argocd/
│   └── camunda8-dev-app.yaml
│
├── .gitignore              # Ignore les fichiers générés
└── README.md
```

### ⬇️ Téléchargé automatiquement (lors du déploiement)

```
chart/
├── Chart.lock              # Généré par Helm
└── charts/                 # Généré par Helm
    └── camunda-platform-10.3.3.tgz  # Téléchargé depuis helm.camunda.io
```

**Ces fichiers sont dans `.gitignore` - vous ne les committez PAS !**

---

## 🚫 Erreurs courantes

### ❌ Erreur 1 : Cloner le repo Camunda

```bash
# NE FAITES PAS ÇA !
git clone https://github.com/camunda/camunda-platform-helm.git
```

### ❌ Erreur 2 : Copier les fichiers Camunda

```bash
# NE FAITES PAS ÇA !
cp -r camunda-platform-helm/charts/camunda-platform/* ./chart/
```

### ❌ Erreur 3 : Committer les fichiers téléchargés

```bash
# NE FAITES PAS ÇA !
git add chart/charts/
git add Chart.lock
git commit -m "Add Camunda files"
```

### ✅ Ce qu'il faut faire

```bash
# Créez UNIQUEMENT vos fichiers de configuration
# Chart.yaml, values-*.yaml, etc.
git add chart/Chart.yaml
git add chart/values-dev.yaml
git commit -m "Configuration Camunda 8"
git push

# Helm télécharge automatiquement le reste !
```

---

## 📊 Schéma visuel

```
┌─────────────────────────────────────────┐
│  Votre Repository Git                    │
│  (quelques fichiers YAML - < 10 Ko)     │
│                                          │
│  chart/Chart.yaml                        │
│  chart/values-dev.yaml                   │
│  argocd/camunda8-dev-app.yaml           │
└────────────────┬────────────────────────┘
                 │
                 │ git push
                 ↓
┌─────────────────────────────────────────┐
│  GitHub/GitLab                           │
│  (stocke votre configuration)            │
└────────────────┬────────────────────────┘
                 │
                 │ ArgoCD surveille
                 ↓
┌─────────────────────────────────────────┐
│  ArgoCD sur Kubernetes                   │
│  Lit Chart.yaml                          │
└────────────────┬────────────────────────┘
                 │
                 │ Voit dependency: https://helm.camunda.io
                 ↓
┌─────────────────────────────────────────┐
│  Helm télécharge automatiquement         │
│  depuis https://helm.camunda.io          │
│  (chart Camunda ~20 Mo)                  │
└────────────────┬────────────────────────┘
                 │
                 │ Merge avec values-dev.yaml
                 ↓
┌─────────────────────────────────────────┐
│  Déploiement sur Kubernetes              │
│  Camunda 8 est installé ! 🎉            │
└─────────────────────────────────────────┘
```

---

## 🎓 Résumé en 3 points

1. **Votre repo = configuration uniquement** (fichiers YAML)
2. **Helm télécharge Camunda automatiquement** depuis internet
3. **Vous ne clonez JAMAIS le code source de Camunda**

---

## 🤝 Analogie finale

### Installer une application sur votre téléphone

**❌ Vous ne faites PAS ça :**

- Aller sur GitHub
- Cloner le code source de l'app
- Compiler l'app
- L'installer manuellement

**✅ Vous faites ça :**

- Ouvrir l'App Store
- Cliquer sur "Installer"
- L'app se télécharge et s'installe automatiquement

### Même principe avec Helm !

**❌ Vous ne faites PAS ça :**

- Cloner le repo Camunda
- Copier tous les fichiers
- Les mettre dans votre Git

**✅ Vous faites ça :**

- Créer `Chart.yaml` avec l'URL du chart
- Faire `git push`
- Helm télécharge et installe automatiquement

---

## 💡 Si vous voulez vraiment voir le code Camunda

Si vous êtes curieux et voulez voir le code source :

### Option 1 : Voir sur GitHub (recommandé)

```
https://github.com/camunda/camunda-platform-helm
```

### Option 2 : Extraire le chart téléchargé (avancé)

```bash
# Après un déploiement local
cd chart/charts/
tar -xzf camunda-platform-10.3.3.tgz
ls -la camunda-platform/
```

**Mais vous n'avez PAS besoin de faire ça pour déployer !**

---

## ✅ Checklist finale

Cochez ce que vous devez faire :

- [ ] Créer mon repository Git
- [ ] Créer `chart/Chart.yaml` avec la référence à Camunda
- [ ] Créer `chart/values-dev.yaml` avec ma configuration
- [ ] Créer `argocd/camunda8-dev-app.yaml`
- [ ] Ajouter `charts/` et `Chart.lock` dans `.gitignore`
- [ ] Committer et pusher mes fichiers
- [ ] Déployer avec ArgoCD

**Ce que je ne dois PAS faire :**

- [ ] ❌ Cloner le repo Camunda
- [ ] ❌ Copier les fichiers sources de Camunda
- [ ] ❌ Committer `charts/` ou `Chart.lock`
- [ ] ❌ Télécharger manuellement le chart Helm

---

**Vous avez tout compris ? Si oui, vous êtes prêt à déployer ! 🚀**
