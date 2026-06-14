# Flask DevOps Automation Mini Project

Application Flask simple pour apprendre un pipeline CI/CD complet avec GitHub Actions, Docker et Docker Hub.

## Objectifs du projet

- Créer une application Flask minimale
- Ajouter des tests automatisés avec Pytest
- Conteneuriser l'application avec Docker
- Exécuter une CI avec GitHub Actions
- Construire et publier une image Docker automatiquement
- Préparer le projet pour un futur déploiement Linux ou cloud

## Stack technique

- Python 3.10
- Flask
- Pytest
- Docker
- GitHub Actions
- Docker Hub

## Structure du projet

```text
flask-devops-automation-mini-project/
├── app.py
├── requirements.txt
├── Dockerfile
├── tests/
│   └── test_app.py
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── docs/
│   ├── architecture.md
│   ├── linkedin-description.md
│   └── cv-description.md
└── README.md
```

## Fonctionnement de l'application

- `GET /` renvoie un message JSON de bienvenue
- `GET /health` renvoie un statut de santé utile pour les tests et les futurs déploiements

## Concepts appris

- **CI**: validation automatique du code à chaque changement
- **CD**: livraison ou déploiement automatisé après validation
- **Pipeline**: chaîne d'étapes automatisées
- **Workflow**: fichier YAML qui décrit le pipeline GitHub Actions
- **Job**: bloc d'étapes exécutées sur un runner
- **Step**: action individuelle dans un job
- **Runner**: machine qui exécute le workflow
- **Docker Image**: modèle immuable de l'application
- **Docker Container**: instance en cours d'exécution de l'image
- **Docker Registry**: registre qui stocke les images
- **Docker Hub**: registry public/privé utilisé ici
- **Secrets GitHub**: stockage sécurisé des identifiants sensibles
- **Variables d'environnement**: paramètres externes au code
- **Tests automatisés**: vérification rapide du comportement applicatif
- **Build**: construction de l'image Docker
- **Deploy**: mise à disposition de l'application sur une cible

## Exécution locale

### 1. Créer et activer l'environnement virtuel

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

### 2. Installer les dépendances

```powershell
pip install -r requirements.txt
```

### 3. Lancer les tests

```powershell
pytest -q
```

### 4. Lancer l'application en local

```powershell
python app.py
```

Ouvre ensuite:

- `http://127.0.0.1:5000/`
- `http://127.0.0.1:5000/health`

## Lancer avec Docker

```powershell
docker build -t benharbfarah/ci_cd_pipeline .
docker run -p 5000:5000 benharbfarah/ci_cd_pipeline
```

## CI/CD GitHub Actions

Le workflow `.github/workflows/ci-cd.yml` fait deux choses:

- Il exécute les tests sur chaque `push` et `pull_request`
- Il construit l'image Docker à chaque `push`
- Il pousse l'image sur Docker Hub `benharbfarah/ci_cd_pipeline` sur la branche `main` uniquement si `DOCKERHUB_TOKEN` est configuré

## Configuration GitHub requise

Dans ton dépôt GitHub, ajoute:

- `Secret`: `DOCKERHUB_TOKEN`

## Configuration Docker Hub

Créer un compte Docker Hub puis:

1. Vérifie que le repository `benharbfarah/ci_cd_pipeline` existe bien
2. Génère un access token Docker Hub
3. Ajoute ce token dans GitHub Secrets sous `DOCKERHUB_TOKEN`

## Important

Sans `DOCKERHUB_TOKEN`, le workflow continue d’exécuter les tests et de construire l’image, mais il ne publie pas l’image sur Docker Hub.

## Schéma du pipeline

Voir [`docs/architecture.md`](docs/architecture.md)

## Descriptions projet

- Voir [`docs/linkedin-description.md`](docs/linkedin-description.md)
- Voir [`docs/cv-description.md`](docs/cv-description.md)

## Ce que fait le pipeline

1. Un `push` déclenche GitHub Actions
2. Le runner GitHub récupère le code
3. Les dépendances Python sont installées
4. Les tests Pytest sont exécutés
5. Si tout passe, Docker construit l'image
6. Sur `main`, l'image est poussée vers Docker Hub

## Erreurs fréquentes

- `pytest` introuvable: vérifie l'environnement virtuel
- `docker login` échoue: vérifie le token Docker Hub
- `build` échoue: vérifie le `Dockerfile`
- workflow GitHub non déclenché: vérifie que le fichier est bien dans `.github/workflows/`

## Prochaines évolutions

- Ajouter un lint avec `ruff`
- Ajouter des tests d'intégration
- Déployer l'image sur un serveur Linux
- Ajouter un health check de déploiement
- Intégrer un rollback automatique
