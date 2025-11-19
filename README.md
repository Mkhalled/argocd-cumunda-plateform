# 🚀 Déploiement Camunda 8 - Structure Simplifiée

Projet Camunda 8 utilisant **Helm + GitLab CI** (sans ArgoCD).

---

## 📁 Structure du projet

```
camunda8-deployement/
├── camunda-platform/         # Configuration Helm
│   ├── Chart.yaml            # Référence au chart Camunda officiel
│   └── values-dev.yaml       # Configuration DEV
│
├── .gitlab-ci.yml            # Pipeline de déploiement
├── .env_vars                 # Variables d'environnement
├── modules                   # Configuration des environnements
│
├── docs/                     # Documentation complète
│   ├── EXPLICATIONS.md
│   ├── COMPRENDRE-HELM-ARGOCD.md
│   └── FAQ-DEBUTANTS.md
│
└── scripts/
    └── test-network.sh
```

---

## 🎯 Workflow de déploiement

```
1. Modifier camunda-platform/values-dev.yaml
   ↓
2. git commit + push
   ↓
3. GitLab CI détecte le changement
   ↓
4. helm upgrade --install camunda8-dev camunda-platform/
   ↓
5. Camunda 8 déployé ! 🎉
```

**C'est identique à votre backend !** Pas d'ArgoCD, juste Helm + GitLab CI.

---

## ⚙️ Configuration avant déploiement

### 1️⃣ Remplir les 🔴 dans `camunda-platform/values-dev.yaml`

```yaml
labels:
  appcode: 🔴 APxxxxx # Code application
  appshortname: 🔴 CAMUNDA8
  opscontact: 🔴 votre_equipe_ops@votre-entreprise.com
  ecosystem: 🔴 ecXXXiXXXXXX
  k8s_cluster: 🔴 kuXXXiXXXXXX
  k8s_namespace: 🔴 nsXXXiXXXXXX

global:
  ingress:
    host: "🔴 camunda-dev.votre-domaine.com"

zeebe:
  pvcStorageClassName: "🔴 votre-storage-class"

elasticsearch:
  volumeClaimTemplate:
    storageClassName: "🔴 votre-storage-class"
```

### 2️⃣ Remplir `.env_vars`

```yaml
nprd:
  default:
    ecosystem: 🔴 ecXXXiXXXXXX
    cluster: https://🔴kuXXXiXXXXXX.votre-domaine.com:XXXXX
    vault_namespace: 🔴 VOTRE_NAMESPACE/VAULT

  envs:
    dev:
      namespace: 🔴 nsXXXiXXXXXX
```

### 3️⃣ Remplir `.gitlab-ci.yml`

```yaml
deploy:dev:
  script:
    - export NAMESPACE="🔴nsXXXiXXXXXX"
    - export CLUSTER="https://🔴kuXXXiXXXXXX.votre-domaine.com:XXXXX"
```

---

## 🚀 Déploiement

### Option 1 : Via GitLab CI (recommandé)

```bash
# 1. Modifier la configuration
vim camunda-platform/values-dev.yaml

# 2. Commit et push
git add camunda-platform/values-dev.yaml
git commit -m "feat: configure Camunda 8 for dev"
git push origin main

# 3. GitLab CI déploie automatiquement !
```

### Option 2 : Manuel (pour tester localement)

```bash
# 1. Aller dans le dossier
cd camunda-platform/

# 2. Télécharger les dépendances
helm dependency update

# 3. Valider
helm lint . -f values-dev.yaml

# 4. Déployer
helm upgrade --install camunda8-dev . \
  --namespace nsXXXiXXXXXX \
  --values values-dev.yaml \
  --create-namespace \
  --wait \
  --timeout 15m

# 5. Vérifier
kubectl get pods -n nsXXXiXXXXXX
```

---

## 🔐 Sécurité

✅ Toutes les configurations respectent les standards d'entreprise :

- `runAsNonRoot: true`
- `capabilities: drop ALL`
- `seccompProfile: RuntimeDefault`
- Probes configurées (startup, readiness, liveness)
- Resources requests = limits pour CPU
- Labels standardisés
- Image pullPolicy: Always

---

## 📊 Composants Camunda 8

| Composant         | Description        | URL                                    |
| ----------------- | ------------------ | -------------------------------------- |
| **Zeebe**         | Moteur de workflow | -                                      |
| **Zeebe Gateway** | API gRPC/REST      | 🔴 zeebe-gateway-dev.votre-domaine.com |
| **Operate**       | Monitoring         | 🔴 operate-dev.votre-domaine.com       |
| **Tasklist**      | Gestion tâches     | 🔴 tasklist-dev.votre-domaine.com      |
| **Elasticsearch** | Stockage           | -                                      |

---

## 🔍 Dépannage

### Chart pas trouvé dans Artifactory ?

```bash
# Contacter DevOps pour ajouter un proxy vers:
# https://helm.camunda.io
```

### Pods en erreur ?

```bash
# Voir les logs
kubectl logs -n nsXXXiXXXXXX <pod-name>

# Voir les events
kubectl describe pod -n nsXXXiXXXXXX <pod-name>
```

---

## 📚 Documentation

- **[QUICKSTART.md](./QUICKSTART.md)** - Guide rapide 5 minutes
- **[docs/EXPLICATIONS.md](./docs/EXPLICATIONS.md)** - Comprendre Camunda 8
- **[docs/COMPRENDRE-HELM-ARGOCD.md](./docs/COMPRENDRE-HELM-ARGOCD.md)** - Helm dependencies
- **[docs/FAQ-DEBUTANTS.md](./docs/FAQ-DEBUTANTS.md)** - Questions fréquentes
- **[INDEX.md](./INDEX.md)** - Index complet

---

## ✅ Checklist avant déploiement

- [ ] Tous les 🔴 remplis dans `values-dev.yaml`
- [ ] Tous les 🔴 remplis dans `.env_vars`
- [ ] Tous les 🔴 remplis dans `.gitlab-ci.yml`
- [ ] Chart Camunda disponible dans Artifactory
- [ ] Namespace créé dans Kubernetes
- [ ] StorageClass vérifié
- [ ] Ingress domains configurés
- [ ] Secrets TLS créés (si nécessaire)

---

## 📝 Notes

- **Version Camunda** : 8.6.0
- **Version Chart Helm** : 10.3.3
- **Méthode** : GitLab CI + Helm (pas d'ArgoCD)
- **Standards** : Conformes à votre environnement

**Structure identique à votre backend !** 🎉
