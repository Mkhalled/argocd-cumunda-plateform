# 🐳 Guide Docker Compose - Environnement Kubernetes

## 🚀 Démarrage rapide

### 1️⃣ Construire et démarrer le container

```bash
# Dans le dossier du projet
cd /Users/khalledmeneouali/Documents/Workspaces/trainings/camunda8-deployement

# Construire l'image (première fois seulement, ~5 minutes)
docker-compose build

# Démarrer le container en arrière-plan
docker-compose up -d

# Vérifier que le container est en cours d'exécution
docker-compose ps
```

### 2️⃣ Se connecter au container

```bash
# Entrer dans le container
docker-compose exec devcontainer bash

# Vous êtes maintenant dans le container ! 🎉
```

### 3️⃣ Vérifier les outils

```bash
# Une fois dans le container
kubectl version --client
helm version
minikube version
argocd version --client
docker --version
```

---

## 📋 Commandes utiles

### Gestion du container

```bash
# Démarrer le container
docker-compose up -d

# Arrêter le container
docker-compose stop

# Redémarrer le container
docker-compose restart

# Voir les logs
docker-compose logs -f

# Entrer dans le container
docker-compose exec devcontainer bash

# Arrêter et supprimer
docker-compose down

# Arrêter et supprimer (avec volumes)
docker-compose down -v
```

### Depuis votre machine (sans entrer dans le container)

```bash
# Exécuter une commande dans le container
docker-compose exec devcontainer kubectl version --client

# Copier un fichier vers le container
docker cp fichier.txt camunda-devcontainer:/workspace/

# Copier un fichier depuis le container
docker cp camunda-devcontainer:/workspace/fichier.txt .
```

---

## 🎯 Workflow recommandé

### Option A : Travailler dans le container

```bash
# 1. Démarrer le container
docker-compose up -d

# 2. Entrer dans le container
docker-compose exec devcontainer bash

# 3. Travailler normalement
kubectl get nodes
helm list
minikube start

# 4. Quand vous avez fini
exit

# 5. Arrêter le container (si besoin)
docker-compose stop
```

### Option B : Éditeur externe + terminal dans le container

```bash
# 1. Démarrer le container
docker-compose up -d

# 2. Éditer les fichiers avec votre éditeur préféré
#    (IntelliJ, VSCode, etc.) sur votre machine
#    Les fichiers sont synchronisés automatiquement avec le container

# 3. Ouvrir un terminal vers le container
docker-compose exec devcontainer bash

# 4. Exécuter les commandes kubectl/helm dans le container
```

---

## 🔧 Configuration avancée

### Personnaliser les ports

Modifier `docker-compose.yml` :

```yaml
ports:
  - "8080:8080" # ArgoCD
  - "8081:8081" # Operate
  - "VOTRE_PORT:CONTAINER_PORT"
```

Puis redémarrer :

```bash
docker-compose down
docker-compose up -d
```

### Ajouter des outils supplémentaires

Modifier `.devcontainer/Dockerfile`, puis :

```bash
docker-compose build --no-cache
docker-compose up -d
```

### Volumes persistants

Les données suivantes sont **persistées** entre les redémarrages :

- ✅ Cache Helm (`helm-cache`)
- ✅ Données Minikube (`minikube-data`)
- ✅ Config Kubernetes (`kube-config`)
- ✅ Votre code source (monté depuis votre machine)

Pour **réinitialiser complètement** :

```bash
docker-compose down -v
docker-compose up -d
```

---

## 🌐 Accéder aux interfaces Web

### Depuis le container

```bash
# Démarrer un port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Depuis votre navigateur

Les ports sont exposés automatiquement :

- **ArgoCD** : http://localhost:8080
- **Operate** : http://localhost:8081
- **Tasklist** : http://localhost:8082
- **Zeebe Gateway** : localhost:26500

---

## 🐛 Dépannage

### Le container ne démarre pas

```bash
# Vérifier Docker Desktop
docker ps

# Voir les logs d'erreur
docker-compose logs

# Reconstruire proprement
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### "Permission denied" sur /var/run/docker.sock

```bash
# Sur Mac, vérifier que Docker Desktop est démarré
# Sur Linux, ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER
# Puis redémarrer votre session
```

### Le container redémarre en boucle

```bash
# Voir ce qui se passe
docker-compose logs -f devcontainer
```

### Problèmes de ressources

```bash
# Vérifier les ressources Docker
docker stats

# Augmenter les ressources dans Docker Desktop
# Settings > Resources > Memory (min 8 GB recommandé)
```

---

## 💡 Astuces

### Alias pour aller plus vite

Ajouter dans votre `~/.zshrc` ou `~/.bashrc` :

```bash
# Alias pour entrer rapidement dans le container
alias kdev='docker-compose -f /Users/khalledmeneouali/Documents/Workspaces/trainings/camunda8-deployement/docker-compose.yml exec devcontainer bash'

# Alias pour les commandes k8s via le container
alias kube='docker-compose -f /Users/khalledmeneouali/Documents/Workspaces/trainings/camunda8-deployement/docker-compose.yml exec devcontainer kubectl'
```

Puis :

```bash
source ~/.zshrc  # ou ~/.bashrc

# Maintenant vous pouvez faire :
kdev             # Entre directement dans le container
kube get nodes   # Exécute kubectl depuis votre terminal
```

### Tmux dans le container

```bash
# Installer tmux dans le container
docker-compose exec devcontainer bash
apt-get update && apt-get install -y tmux

# Utiliser tmux
tmux
```

---

## 📊 Structure

```
camunda8-deployement/
├── docker-compose.yml          # Configuration Docker Compose
├── .devcontainer/
│   └── Dockerfile              # Image avec tous les outils
├── camunda-platform/           # Charts Helm
└── scripts/                    # Scripts utiles
```

---

## 🎯 Prochaines étapes

1. ✅ **Container démarré** ← Vous êtes ici !
2. ⏭️ **Démarrer Minikube** dans le container
3. ⏭️ **Installer ArgoCD**
4. ⏭️ **Déployer Camunda 8**

---

**Prêt à démarrer ? Lancez `docker-compose up -d` ! 🚀**
