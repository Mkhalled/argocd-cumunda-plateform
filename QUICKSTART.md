# ⚡ Guide Rapide - Déploiement en 5 minutes

Pour les pressés ! Suivez ces étapes :

## 1️⃣ Modifier la configuration

Éditez `helm/values-dev.yaml` et changez **uniquement** :

- `votre-domaine.com` → votre vrai domaine (4 endroits)

Éditez `argocd/camunda8-dev-app.yaml` et changez :

- L'URL du repository Git → votre repository
- La branche → votre branche (ex: `main` ou `master`)

## 2️⃣ Commit et push

```bash
git add .
git commit -m "Config Camunda 8 dev"
git push
```

## 3️⃣ Déployer avec ArgoCD

```bash
kubectl apply -f argocd/camunda8-dev-app.yaml
```

## 4️⃣ Attendre et vérifier

```bash
# Voir les pods se créer (Ctrl+C pour arrêter)
kubectl get pods -n camunda-dev -w
```

Attendez que tous les pods soient `Running` (5-10 min)

## 5️⃣ Accéder aux interfaces

### Avec ingress configuré :

- Operate : `https://operate-dev.votre-domaine.com`
- Tasklist : `https://tasklist-dev.votre-domaine.com`

### Sans ingress (port-forward) :

```bash
# Operate
kubectl port-forward -n camunda-dev svc/camunda-platform-operate 8081:80
# → http://localhost:8081

# Tasklist
kubectl port-forward -n camunda-dev svc/camunda-platform-tasklist 8082:80
# → http://localhost:8082
```

**Login** : `demo` / `demo`

## ✅ C'est fait !

Consultez le [README complet](README.md) pour plus de détails.

---

## 🚨 Problème ?

```bash
# Voir ce qui ne va pas
kubectl get pods -n camunda-dev
kubectl describe pod <nom-du-pod-en-erreur> -n camunda-dev
kubectl logs <nom-du-pod> -n camunda-dev
```
