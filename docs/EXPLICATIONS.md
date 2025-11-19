# 📖 Comprendre Camunda 8 - Explications pour débutants

## Qu'est-ce que Camunda 8 ?

Camunda 8 est une plateforme qui permet d'**orchestrer des processus métier** de manière automatisée.

### Analogie simple 🎯

Imaginez une recette de cuisine :

- **BPMN** = La recette écrite
- **Zeebe** = Le chef qui suit la recette
- **Operate** = L'écran de surveillance en cuisine
- **Tasklist** = La liste des tâches pour les commis

## Les composants expliqués

### 1. Zeebe (Le moteur) 🚗

**C'est quoi ?** Le cœur de Camunda 8, le moteur qui exécute vos processus.

**Analogie** : Comme un chef d'orchestre qui coordonne tous les musiciens.

**Dans notre config** :

```yaml
zeebe:
  clusterSize: 1 # Nombre de "chefs" (1 suffit pour dev)
  partitionCount: 1 # Nombre de "partitions de travail"
```

### 2. Zeebe Gateway (La porte d'entrée) 🚪

**C'est quoi ?** Le point d'entrée pour vos applications qui veulent démarrer des processus ou récupérer des tâches.

**Analogie** : Comme la réception d'un hôtel - tout le monde passe par là.

**Utilisation** :

- Vos applications se connectent au Gateway
- Le Gateway transmet à Zeebe
- Protocole : gRPC (comme une API mais plus rapide)

### 3. Operate (Le tableau de bord) 📊

**C'est quoi ?** Une interface web pour **voir et surveiller** vos processus en cours.

**Vous pouvez** :

- Voir tous les processus en cours d'exécution
- Identifier les processus bloqués
- Analyser les erreurs
- Annuler ou relancer des processus

**Accès** : Interface web avec login/mot de passe

### 4. Tasklist (La liste de tâches) ✅

**C'est quoi ?** Une interface web pour que les **utilisateurs humains** traitent leurs tâches.

**Exemple d'usage** :

- Un processus d'approbation de congés
- Une validation de commande
- Une revue de document

**Accès** : Interface web, chaque utilisateur voit ses tâches

### 5. Elasticsearch (La mémoire) 💾

**C'est quoi ?** Une base de données qui stocke l'historique de tout ce qui se passe.

**Pourquoi ?** Operate et Tasklist ont besoin de stocker et rechercher dans l'historique.

**Note** : Consomme pas mal de ressources (d'où la config réduite en dev)

## Workflow d'utilisation typique

```
1. Développeur → Crée un processus BPMN (avec Modeler)
   ↓
2. Développeur → Déploie le processus (via Zeebe Gateway)
   ↓
3. Application → Démarre une instance du processus
   ↓
4. Zeebe → Exécute les étapes automatiques
   ↓
5. Utilisateur → Voit sa tâche dans Tasklist
   ↓
6. Utilisateur → Complète la tâche
   ↓
7. Zeebe → Continue le processus
   ↓
8. Tout le monde → Peut suivre dans Operate
```

## Comprendre la configuration

### Ressources (CPU/Memory)

```yaml
resources:
  requests:
    cpu: "500m" # 0.5 CPU minimum
    memory: "512Mi" # 512 MB minimum
  limits:
    cpu: "1000m" # 1 CPU maximum
    memory: "1Gi" # 1 GB maximum
```

- **requests** : Ce dont le pod a besoin au minimum
- **limits** : Le maximum qu'il peut utiliser

### Réplication et haute disponibilité

```yaml
zeebe:
  clusterSize: 1 # En dev : 1 seul nœud
  partitionCount: 1 # En dev : 1 partition
  replicationFactor: 1 # En dev : pas de réplication
```

**En production**, on augmente ces valeurs pour la redondance.

### Persistence (Stockage)

```yaml
pvcSize: "10Gi" # 10 GB de stockage
```

Les données des processus sont stockées de manière persistante.

## ArgoCD - Qu'est-ce que c'est ?

### Le principe

ArgoCD est un outil de **GitOps** :

- Votre configuration est dans **Git**
- ArgoCD **surveille** Git
- Si Git change, ArgoCD **synchronise** automatiquement Kubernetes

### Analogie 🔄

Git = Plans d'architecte
ArgoCD = Chef de chantier qui suit les plans
Kubernetes = Le chantier

Si vous changez les plans → Le chef de chantier met à jour le chantier

### Dans notre cas

1. Vous modifiez `values-dev.yaml`
2. Vous faites `git push`
3. ArgoCD détecte le changement
4. ArgoCD redéploie automatiquement

**Avantage** : Tout est versionné, traçable, et reproductible !

## Structure du projet

```
camunda8-deployement/
│
├── helm/                          # Configuration Helm
│   ├── Chart.yaml                 # Définition du chart
│   └── values-dev.yaml            # Valeurs pour l'env dev
│
├── argocd/                        # Configuration ArgoCD
│   ├── camunda8-dev-app.yaml     # Définition de l'application
│   └── namespace.yaml             # Création du namespace
│
├── docs/                          # Documentation
│
├── README.md                      # Guide complet
└── QUICKSTART.md                  # Guide rapide
```

## Commandes utiles pour débutants

### Voir l'état des choses

```bash
# Tous les pods du namespace
kubectl get pods -n camunda-dev

# Détails d'un pod
kubectl describe pod <nom-du-pod> -n camunda-dev

# Logs d'un pod
kubectl logs <nom-du-pod> -n camunda-dev

# Suivre les logs en temps réel
kubectl logs -f <nom-du-pod> -n camunda-dev
```

### Vérifier les services

```bash
# Tous les services
kubectl get svc -n camunda-dev

# Tous les ingress (URLs externes)
kubectl get ingress -n camunda-dev
```

### Redémarrer un pod

```bash
# Supprimer un pod (il va se recréer automatiquement)
kubectl delete pod <nom-du-pod> -n camunda-dev
```

## Glossaire

- **BPMN** : Notation standard pour modéliser des processus
- **Pod** : Un conteneur qui tourne sur Kubernetes
- **Service** : Un point d'accès réseau vers des pods
- **Ingress** : Une règle pour exposer un service à l'extérieur
- **Namespace** : Un espace isolé dans Kubernetes
- **PVC** : Persistent Volume Claim - espace disque pour les données
- **Helm** : Gestionnaire de packages pour Kubernetes
- **Chart** : Un package Helm (template + valeurs)

## Questions fréquentes

### Combien de temps prend le déploiement ?

Entre 5 et 15 minutes, selon votre cluster.

### Pourquoi Elasticsearch prend autant de ressources ?

C'est une base de données qui indexe tout. On peut réduire en dev, mais pas trop.

### Puis-je désactiver certains composants ?

Oui ! Dans `values-dev.yaml`, mettez `enabled: false` pour :

- `optimize` (analyse avancée)
- `connectors` (intégrations)
- `identity` (gestion utilisateurs)

### Comment changer le mot de passe par défaut ?

En activant `identity` et en configurant l'authentification.

### Ça consomme combien de ressources au total ?

En configuration minimale dev : ~4 CPU et ~6 GB RAM

## Pour aller plus loin

1. **Créez votre premier processus** :

   - Utilisez le [Modeler web](https://modeler.cloud.camunda.io/)
   - Suivez un [tutorial](https://docs.camunda.io/docs/next/guides/)

2. **Déployez un processus** :

   - Utilisez [zbctl](https://docs.camunda.io/docs/next/apis-tools/cli-client/) (CLI)
   - Ou une [bibliothèque client](https://docs.camunda.io/docs/next/apis-tools/working-with-apis-tools/) (Java, Node.js, etc.)

3. **Intégrez avec votre application** :
   - Consultez les [APIs](https://docs.camunda.io/docs/next/apis-tools/working-with-apis-tools/)
   - Essayez les [Connectors](https://docs.camunda.io/docs/components/connectors/introduction/)

---

**Bonne découverte de Camunda 8 ! 🎓**
