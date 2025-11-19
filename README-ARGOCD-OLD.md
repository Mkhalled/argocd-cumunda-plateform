# 🚀 Déploiement Camunda 8 avec ArgoCD - Guide Débutant

Ce guide vous accompagne pas à pas pour déployer Camunda 8 dans votre environnement dev avec ArgoCD.

> **❓ Question fréquente** : [Est-ce que je dois cloner le repository Camunda ?](docs/NE-PAS-CLONER-CAMUNDA.md)  
> **Réponse** : **NON !** Helm télécharge automatiquement Camunda depuis internet. Votre repo contient uniquement les fichiers de configuration (quelques Ko).

## 📋 Table des matières

1. [Prérequis](#prérequis)
2. [Architecture](#architecture)
3. [Configuration](#configuration)
4. [Déploiement](#déploiement)
5. [Accès aux interfaces](#accès-aux-interfaces)
6. [Dépannage](#dépannage)
7. [Questions fréquentes](#questions-fréquentes)

---

## ✅ Prérequis

Avant de commencer, assurez-vous d'avoir :

- [ ] Un cluster Kubernetes accessible
- [ ] ArgoCD installé sur le cluster
- [ ] `kubectl` configuré pour accéder à votre cluster
- [ ] Accès Git au repository
- [ ] (Optionnel) Un Ingress Controller (nginx, traefik, etc.)

### Vérifier vos outils

```bash
# Vérifier kubectl
kubectl version

# Vérifier ArgoCD
kubectl get pods -n argocd

# Vérifier l'accès au cluster
kubectl get nodes
```

---

## 🏗️ Architecture

Camunda 8 est composé de plusieurs services :

```
┌─────────────────────────────────────────────┐
│           Camunda 8 Platform                │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │  Zeebe   │  │ Operate  │  │ Tasklist │ │
│  │ (Moteur) │  │(Monitoring)│(Tâches)   │ │
│  └──────────┘  └──────────┘  └──────────┘ │
│                                             │
│  ┌──────────────┐  ┌──────────────────┐   │
│  │   Gateway    │  │ Elasticsearch    │   │
│  │  (API)       │  │   (Stockage)     │   │
│  └──────────────┘  └──────────────────┘   │
└─────────────────────────────────────────────┘
```

---

## ⚙️ Configuration

### 1. Cloner le repository

```bash
git clone https://github.com/votre-organisation/camunda8-deployement.git
cd camunda8-deployement
```

### 2. Modifier les fichiers de configuration

#### 📝 `helm/values-dev.yaml`

**IMPORTANT** : Modifiez ces valeurs selon votre environnement :

```yaml
global:
  ingress:
    host: "camunda-dev.votre-domaine.com" # 🔴 Votre domaine

zeebe-gateway:
  ingress:
    host: "zeebe-dev.votre-domaine.com" # 🔴 Votre domaine

operate:
  ingress:
    host: "operate-dev.votre-domaine.com" # 🔴 Votre domaine

tasklist:
  ingress:
    host: "tasklist-dev.votre-domaine.com" # 🔴 Votre domaine
```

#### 📝 `argocd/camunda8-dev-app.yaml`

Modifiez l'URL de votre repository Git :

```yaml
source:
  repoURL: https://github.com/votre-organisation/camunda8-deployement.git # 🔴 Votre repo
  targetRevision: main # 🔴 Votre branche
```

### 3. Commit et push

```bash
git add .
git commit -m "Configuration initiale Camunda 8 dev"
git push origin main
```

---

## 🚀 Déploiement

### Étape 1 : Créer le namespace (optionnel, ArgoCD peut le faire)

```bash
kubectl apply -f argocd/namespace.yaml
```

### Étape 2 : Déployer l'application ArgoCD

```bash
kubectl apply -f argocd/camunda8-dev-app.yaml
```

### Étape 3 : Vérifier le statut dans ArgoCD

#### Option A : Via l'interface web ArgoCD

1. Ouvrez l'interface ArgoCD (demandez l'URL à votre admin)
2. Vous devriez voir l'application `camunda8-dev`
3. Cliquez dessus pour voir les détails

#### Option B : Via la CLI

```bash
# Vérifier le statut de l'application
argocd app get camunda8-dev

# Synchroniser manuellement si nécessaire
argocd app sync camunda8-dev

# Voir les logs
argocd app logs camunda8-dev
```

#### Option C : Via kubectl

```bash
# Voir les pods qui se déploient
kubectl get pods -n camunda-dev -w

# Voir tous les services
kubectl get all -n camunda-dev

# Voir les ingress
kubectl get ingress -n camunda-dev
```

### Étape 4 : Attendre le déploiement complet

Le déploiement peut prendre **5-15 minutes**. Les pods doivent être en état `Running` :

```bash
kubectl get pods -n camunda-dev

# Exemple de sortie attendue :
# NAME                              READY   STATUS    RESTARTS   AGE
# zeebe-0                           1/1     Running   0          5m
# zeebe-gateway-xxx                 1/1     Running   0          5m
# operate-xxx                       1/1     Running   0          5m
# tasklist-xxx                      1/1     Running   0          5m
# elasticsearch-master-0            1/1     Running   0          6m
```

---

## 🌐 Accès aux interfaces

### URLs des services

Si vous avez configuré les ingress :

- **Operate** (monitoring) : `https://operate-dev.votre-domaine.com`
- **Tasklist** (tâches) : `https://tasklist-dev.votre-domaine.com`
- **Zeebe Gateway** (API) : `grpc://zeebe-dev.votre-domaine.com`

### Accès local via Port-Forward

Si vous n'avez pas d'ingress configuré, utilisez le port-forwarding :

```bash
# Operate
kubectl port-forward -n camunda-dev svc/camunda-platform-operate 8081:80
# Accès: http://localhost:8081

# Tasklist
kubectl port-forward -n camunda-dev svc/camunda-platform-tasklist 8082:80
# Accès: http://localhost:8082

# Zeebe Gateway (pour les clients)
kubectl port-forward -n camunda-dev svc/camunda-platform-zeebe-gateway 26500:26500
```

### Identifiants par défaut

- **Username** : `demo`
- **Password** : `demo`

---

## 🔧 Dépannage

### Les pods ne démarrent pas

```bash
# Voir les détails d'un pod
kubectl describe pod <nom-du-pod> -n camunda-dev

# Voir les logs d'un pod
kubectl logs <nom-du-pod> -n camunda-dev

# Voir les événements du namespace
kubectl get events -n camunda-dev --sort-by='.lastTimestamp'
```

### L'application ArgoCD est en état "OutOfSync"

```bash
# Forcer la synchronisation
argocd app sync camunda8-dev --force

# Ou via kubectl
kubectl patch application camunda8-dev -n argocd --type merge -p '{"operation":{"sync":{}}}'
```

### Erreur de ressources insuffisantes

Réduisez les ressources dans `helm/values-dev.yaml` :

```yaml
zeebe:
  resources:
    requests:
      cpu: "250m" # Réduit de 500m
      memory: "256Mi" # Réduit de 512Mi
```

### Problèmes d'Elasticsearch

```bash
# Vérifier les pods Elasticsearch
kubectl get pods -n camunda-dev | grep elasticsearch

# Augmenter le stockage si nécessaire dans values-dev.yaml
elasticsearch:
  volumeClaimTemplate:
    resources:
      requests:
        storage: "20Gi"  # Augmenté de 15Gi
```

---

## ❓ Questions fréquentes

### Est-ce que je dois cloner le repository Camunda ?

**NON !** Lisez [cette explication détaillée](docs/NE-PAS-CLONER-CAMUNDA.md).

Helm télécharge automatiquement le chart Camunda depuis `https://helm.camunda.io`. Votre repository contient uniquement :

- `Chart.yaml` (référence au chart Camunda)
- `values-*.yaml` (votre configuration)
- Configuration ArgoCD

**Taille totale : < 10 Ko** ✅

### Pourquoi on ne fait pas `helm repo add` comme dans la doc officielle ?

Parce qu'on utilise une approche GitOps ! Lisez [cette explication](docs/COMPRENDRE-HELM-ARGOCD.md).

La doc officielle montre l'installation manuelle. Nous utilisons ArgoCD qui gère tout automatiquement en lisant le `Chart.yaml`.

### Combien de temps prend le déploiement ?

Entre 5 et 15 minutes selon votre cluster.

### Puis-je réduire les ressources pour mon environnement dev ?

Oui ! Éditez `helm/values-dev.yaml` et réduisez les valeurs CPU/Memory.

---

## 📚 Ressources utiles

**Documentation interne** :

- [Guide rapide (5 min)](QUICKSTART.md)
- [Explications détaillées](docs/EXPLICATIONS.md)
- [Comprendre Helm + ArgoCD](docs/COMPRENDRE-HELM-ARGOCD.md)
- [FAQ pour débutants](docs/FAQ-DEBUTANTS.md)
- [Checklist](docs/CHECKLIST.md)

**Documentation externe** :

- [Documentation Camunda 8](https://docs.camunda.io/docs/next/)
- [Helm Chart Camunda](https://github.com/camunda/camunda-platform-helm)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Tutoriels Camunda](https://docs.camunda.io/docs/next/guides/)

---

## 🎯 Prochaines étapes

1. **Tester le déploiement** : Déployez un processus simple
2. **Configurer la sécurité** : Activez Identity et configurez l'authentification
3. **Monitoring** : Ajoutez Prometheus/Grafana
4. **CI/CD** : Intégrez vos pipelines de déploiement de processus
5. **Environnements supplémentaires** : Créez des values pour staging/prod

---

## 🆘 Besoin d'aide ?

En cas de problème :

1. Vérifiez les logs des pods
2. Consultez la documentation officielle
3. Contactez votre équipe DevOps
4. Ouvrez une issue sur le repository

---

**Bon déploiement ! 🚀**
