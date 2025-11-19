# 🎯 Checklist de déploiement Camunda 8

Cochez au fur et à mesure de votre progression :

## 📋 Avant de commencer

- [ ] J'ai accès à un cluster Kubernetes
- [ ] ArgoCD est installé sur le cluster
- [ ] Je peux exécuter des commandes `kubectl`
- [ ] J'ai accès Git au repository
- [ ] (Optionnel) Un Ingress Controller est configuré

## ⚙️ Configuration

- [ ] J'ai cloné le repository localement
- [ ] J'ai modifié `helm/values-dev.yaml` :
  - [ ] Changé `votre-domaine.com` (4 endroits)
  - [ ] Vérifié les ressources CPU/Mémoire disponibles
  - [ ] Ajusté la taille des volumes si nécessaire
- [ ] J'ai modifié `argocd/camunda8-dev-app.yaml` :
  - [ ] Changé l'URL du repository Git
  - [ ] Vérifié la branche (main/master)
  - [ ] Vérifié le namespace ArgoCD
- [ ] J'ai fait `git commit` et `git push`

## 🚀 Déploiement

- [ ] J'ai appliqué le namespace : `kubectl apply -f argocd/namespace.yaml`
- [ ] J'ai appliqué l'application ArgoCD : `kubectl apply -f argocd/camunda8-dev-app.yaml`
- [ ] Je vois l'application dans l'interface ArgoCD
- [ ] L'application est en cours de synchronisation

## ⏳ Vérification du déploiement

- [ ] J'ai vérifié que les pods se créent : `kubectl get pods -n camunda-dev -w`
- [ ] Tous les pods sont en état `Running` :
  - [ ] `zeebe-0`
  - [ ] `zeebe-gateway-xxx`
  - [ ] `operate-xxx`
  - [ ] `tasklist-xxx`
  - [ ] `elasticsearch-master-0`
- [ ] Aucun pod n'est en `Error` ou `CrashLoopBackOff`

## 🌐 Test d'accès

### Avec Ingress

- [ ] J'ai testé l'accès à Operate : `https://operate-dev.votre-domaine.com`
- [ ] J'ai testé l'accès à Tasklist : `https://tasklist-dev.votre-domaine.com`
- [ ] Je peux me connecter avec `demo`/`demo`

### Sans Ingress (port-forward)

- [ ] J'ai lancé le port-forward pour Operate
- [ ] J'ai accédé à `http://localhost:8081`
- [ ] J'ai lancé le port-forward pour Tasklist
- [ ] J'ai accédé à `http://localhost:8082`

## 🎓 Prochaines étapes

- [ ] J'ai installé [Camunda Modeler](https://camunda.com/download/modeler/)
- [ ] J'ai suivi un [tutoriel simple](https://docs.camunda.io/docs/next/guides/)
- [ ] J'ai déployé mon premier processus BPMN
- [ ] J'ai testé l'exécution d'une instance
- [ ] J'ai consulté l'instance dans Operate

## 📚 Documentation lue

- [ ] J'ai lu le [QUICKSTART.md](QUICKSTART.md)
- [ ] J'ai lu le [README.md](README.md) complet
- [ ] J'ai consulté [EXPLICATIONS.md](docs/EXPLICATIONS.md)
- [ ] J'ai bookmark la [doc officielle](https://docs.camunda.io/)

## 🛠️ En cas de problème

- [ ] J'ai vérifié les logs des pods
- [ ] J'ai consulté la section Dépannage du README
- [ ] J'ai contacté mon équipe DevOps
- [ ] J'ai ouvert une issue sur le repository

---

**Date de déploiement** : ****\_\_\_****

**Notes** :

```
_____________________________________________________________________
_____________________________________________________________________
_____________________________________________________________________
```
