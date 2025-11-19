# 📚 Index de la documentation

Bienvenue ! Cette documentation est organisée pour les débutants. Suivez l'ordre recommandé ci-dessous.

## 🚀 Démarrage rapide (dans l'ordre)

### 1️⃣ Pour commencer immédiatement

→ [**QUICKSTART.md**](QUICKSTART.md) - 5 minutes pour déployer ⚡

### 2️⃣ Pour comprendre ce que vous faites

→ [**README.md**](README.md) - Guide complet étape par étape 📖

### 3️⃣ Questions essentielles (À LIRE avant de démarrer !)

#### ❓ "Est-ce que je dois cloner le repository Camunda ?"

→ [**docs/NE-PAS-CLONER-CAMUNDA.md**](docs/NE-PAS-CLONER-CAMUNDA.md) - Réponse courte ⚡

→ [**docs/FAQ-DEBUTANTS.md**](docs/FAQ-DEBUTANTS.md) - Réponse détaillée avec exemples 📚

#### ❓ "Pourquoi on ne fait pas `helm repo add` ?"

→ [**docs/COMPRENDRE-HELM-ARGOCD.md**](docs/COMPRENDRE-HELM-ARGOCD.md) - Explications complètes 🎓

---

## 📖 Documentation complète

### Guides pratiques

- [**QUICKSTART.md**](QUICKSTART.md) - Déploiement en 5 minutes
- [**README.md**](README.md) - Guide complet de déploiement
- [**docs/CHECKLIST.md**](docs/CHECKLIST.md) - Checklist à cocher

### Explications pour débutants

- [**docs/EXPLICATIONS.md**](docs/EXPLICATIONS.md) - Comprendre Camunda 8 et ses composants
- [**docs/COMPRENDRE-HELM-ARGOCD.md**](docs/COMPRENDRE-HELM-ARGOCD.md) - Comment fonctionne Helm + ArgoCD
- [**docs/FAQ-DEBUTANTS.md**](docs/FAQ-DEBUTANTS.md) - Questions fréquentes détaillées
- [**docs/NE-PAS-CLONER-CAMUNDA.md**](docs/NE-PAS-CLONER-CAMUNDA.md) - Réponse rapide à LA question

---

## 🎯 Quelle doc lire selon votre besoin ?

### "Je veux juste déployer rapidement"

1. [QUICKSTART.md](QUICKSTART.md)
2. [docs/CHECKLIST.md](docs/CHECKLIST.md)

### "Je veux comprendre comment ça marche"

1. [docs/EXPLICATIONS.md](docs/EXPLICATIONS.md)
2. [docs/COMPRENDRE-HELM-ARGOCD.md](docs/COMPRENDRE-HELM-ARGOCD.md)
3. [README.md](README.md)

### "J'ai des questions spécifiques"

1. [docs/FAQ-DEBUTANTS.md](docs/FAQ-DEBUTANTS.md)
2. [docs/NE-PAS-CLONER-CAMUNDA.md](docs/NE-PAS-CLONER-CAMUNDA.md)

### "Je suis totalement débutant"

Lisez dans cet ordre :

1. [docs/NE-PAS-CLONER-CAMUNDA.md](docs/NE-PAS-CLONER-CAMUNDA.md) - 2 min
2. [docs/EXPLICATIONS.md](docs/EXPLICATIONS.md) - 10 min
3. [QUICKSTART.md](QUICKSTART.md) - 5 min
4. [README.md](README.md) - 20 min

---

## 📂 Structure des fichiers du projet

```
camunda8-deployement/
│
├── 📖 Documentation
│   ├── INDEX.md                     ← Vous êtes ici !
│   ├── README.md                    ← Guide complet
│   ├── QUICKSTART.md                ← Guide rapide
│   └── docs/
│       ├── EXPLICATIONS.md          ← Comprendre Camunda 8
│       ├── COMPRENDRE-HELM-ARGOCD.md← Comprendre le workflow
│       ├── FAQ-DEBUTANTS.md         ← Questions fréquentes
│       ├── NE-PAS-CLONER-CAMUNDA.md ← LA question importante
│       └── CHECKLIST.md             ← Checklist de déploiement
│
├── ⚙️ Configuration Helm
│   └── helm/
│       ├── Chart.yaml               ← Définition du chart
│       └── values-dev.yaml          ← Configuration DEV
│
└── 🚀 Configuration ArgoCD
    └── argocd/
        ├── camunda8-dev-app.yaml    ← Application ArgoCD
        └── namespace.yaml           ← Namespace Kubernetes
```

---

## 🆘 En cas de problème

1. **Consultez** [docs/FAQ-DEBUTANTS.md](docs/FAQ-DEBUTANTS.md)
2. **Vérifiez** les logs : `kubectl logs -n camunda-dev <nom-du-pod>`
3. **Relisez** la section Dépannage du [README.md](README.md)
4. **Contactez** votre équipe DevOps

---

## 🎓 Concepts clés à comprendre

Avant de déployer, assurez-vous de comprendre ces 3 concepts :

### 1. Helm Dependencies (comme npm)

```yaml
# Chart.yaml
dependencies:
  - name: camunda-platform
    repository: https://helm.camunda.io  ← Téléchargé automatiquement
```

### 2. GitOps (tout dans Git)

```
Git = Source de vérité
ArgoCD = Synchronise Git → Kubernetes
```

### 3. Configuration par environnement

```
values-dev.yaml  → Petites ressources
values-int.yaml  → Ressources moyennes
values-prd.yaml  → Haute disponibilité
```

---

## ✅ Prêt à démarrer ?

👉 Commencez par [QUICKSTART.md](QUICKSTART.md)

**Bonne chance ! 🚀**
