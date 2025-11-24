# 🐳 Dev Container - Étape 1 : Installation des outils

## 🎯 Ce qui est installé

✅ **kubectl** - CLI Kubernetes  
✅ **helm** - Gestionnaire de packages Kubernetes  
✅ **minikube** - Kubernetes local  
✅ **argocd** - CLI ArgoCD  
✅ **docker** - Pour minikube (Docker-in-Docker)

---

## 🚀 Comment utiliser

### 1️⃣ Ouvrir dans le Dev Container

1. Ouvrir ce projet dans VSCode
2. Appuyer sur `F1` (ou `Cmd+Shift+P` sur Mac)
3. Chercher : **"Dev Containers: Reopen in Container"**
4. Attendre que le container se construise (3-5 minutes la première fois)

### 2️⃣ Vérifier l'installation

Une fois dans le container, ouvrir un terminal et taper :

```bash
# Vérifier kubectl
kubectl version --client

# Vérifier helm
helm version

# Vérifier minikube
minikube version

# Vérifier argocd
argocd version --client

# Vérifier docker
docker --version
```

### 3️⃣ Tester les alias

```bash
# Recharger la configuration bash
source ~/.bashrc

# Tester les alias
k version --client      # k = kubectl
kgp                     # kgp = kubectl get pods
kgs                     # kgs = kubectl get svc
```

---

## 📋 Alias disponibles

| Alias   | Commande complète   |
| ------- | ------------------- |
| `k`     | `kubectl`           |
| `kgp`   | `kubectl get pods`  |
| `kgs`   | `kubectl get svc`   |
| `kgn`   | `kubectl get nodes` |
| `kdes`  | `kubectl describe`  |
| `klogs` | `kubectl logs -f`   |

---

## 🎯 Prochaines étapes

1. ✅ **Étape 1** : Dev Container avec outils ← **VOUS ÊTES ICI**
2. ⏭️ **Étape 2** : Démarrer Minikube et créer un cluster
3. ⏭️ **Étape 3** : Installer ArgoCD dans le cluster
4. ⏭️ **Étape 4** : Déployer Camunda 8

---

## 🐛 Dépannage

### Le container ne démarre pas

**Cause possible** : Docker Desktop n'est pas démarré

**Solution** :

1. Ouvrir Docker Desktop
2. Attendre que l'icône soit verte
3. Relancer "Reopen in Container" dans VSCode

### Erreur "command not found"

**Solution** :

```bash
source ~/.bashrc
```

### Docker-in-Docker ne fonctionne pas

**Solution** :

```bash
# Vérifier que Docker fonctionne
docker ps

# Si erreur, redémarrer le container
# VSCode: F1 > "Dev Containers: Rebuild Container"
```

---

## 💡 Conseils

- Le terminal est configuré automatiquement avec des **alias** et **auto-completion**
- Tous les outils sont déjà installés, **pas besoin d'installer quoi que ce soit** sur votre machine
- L'environnement est **isolé**, vous pouvez tout casser sans risque 😉

---

**Prêt pour l'étape 2 ? Dites-le moi ! 🚀**
