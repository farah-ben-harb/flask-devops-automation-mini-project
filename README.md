# Flask DevOps Automation Mini Project

A practical Flask project that demonstrates a complete CI/CD workflow with GitHub Actions, Docker, Pytest, and Docker Hub.

## Overview

This repository is designed as a hands-on DevOps learning project. It shows how to:

- build a small Flask application
- test it automatically with Pytest
- package it with Docker
- run CI on every push and pull request
- publish a Docker image to Docker Hub from GitHub Actions

## Tech Stack

- Python 3.10
- Flask
- Pytest
- Docker
- GitHub Actions
- Docker Hub

## Project Structure

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
└── README.md
```

## Application Features

- `GET /` returns a JSON welcome message
- `GET /health` returns a simple health check response

## Concepts Covered

- **CI**: automatically validate code on every change
- **CD**: automatically deliver or deploy code after validation
- **Pipeline**: a chain of automated stages
- **Workflow**: the GitHub Actions YAML file that defines the pipeline
- **Job**: a group of related steps executed on a runner
- **Step**: one action inside a job
- **Runner**: the machine that executes the workflow
- **Docker Image**: the packaged application artifact
- **Docker Container**: a running instance of the image
- **Docker Registry**: a service that stores Docker images
- **Docker Hub**: the registry used in this project
- **GitHub Secrets**: secure storage for sensitive values
- **Environment Variables**: runtime configuration outside the code
- **Automated Tests**: repeatable checks that protect the application
- **Build**: create the Docker image
- **Deploy**: run the application on a target environment

## Local Setup

### 1. Create a virtual environment

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

### 2. Install dependencies

```powershell
pip install -r requirements.txt
```

### 3. Run the tests

```powershell
pytest -q
```

### 4. Start the application

```powershell
python app.py
```

Open:

- `http://127.0.0.1:5000/`
- `http://127.0.0.1:5000/health`

## Run with Docker

```powershell
docker build -t benharbfarah/ci_cd_pipeline .
docker run -p 5000:5000 benharbfarah/ci_cd_pipeline
```

## CI/CD Workflow

The GitHub Actions workflow does the following:

- runs Pytest on every `push` and `pull_request`
- builds the Docker image on every `push`
- pushes the Docker image to Docker Hub on `main` when `DOCKERHUB_TOKEN` is configured

## GitHub Configuration

Add this secret in your GitHub repository:

- `DOCKERHUB_TOKEN`

## Docker Hub Configuration

1. Make sure the Docker Hub repository `benharbfarah/ci_cd_pipeline` exists
2. Generate a Docker Hub access token
3. Add that token to GitHub Secrets as `DOCKERHUB_TOKEN`

## How to Test the Pipeline

### Test 1: Validate CI without Docker Hub publishing

This test checks that the pipeline runs the automated tests and builds the image.

1. Push a small change to any branch.
2. Open the GitHub repository.
3. Go to the `Actions` tab.
4. Confirm that the `Run tests` job passes.
5. Confirm that the `Build and push Docker image` job builds successfully.

### Test 2: Test pull request validation

1. Create a new branch.
2. Make a small code change.
3. Open a pull request to `main`.
4. Check that the workflow runs automatically.
5. Confirm the tests pass before merge.

### Test 3: Test Docker Hub publishing

After adding `DOCKERHUB_TOKEN`:

1. Push a commit directly to `main`.
2. Open the `Actions` tab in GitHub.
3. Wait for the workflow to finish successfully.
4. Open Docker Hub.
5. Confirm that the image `benharbfarah/ci_cd_pipeline` appears with tags like:
   - `latest`
   - the commit SHA

### Optional manual test

You can also use `workflow_dispatch`:

1. Open the workflow in GitHub Actions.
2. Click `Run workflow`.
3. Check the job logs.

## Expected Result

When the pipeline is healthy:

- tests pass
- the Docker image is built
- the image is pushed to Docker Hub on `main`
- the workflow appears green in GitHub Actions

## Common Issues

- `ModuleNotFoundError: No module named 'app'`: make sure the workflow sets `PYTHONPATH`
- `pytest` not found: install dependencies in the virtual environment
- Docker login failure: verify `DOCKERHUB_TOKEN`
- Image not pushed: confirm the commit was made on `main`
- Workflow not triggered: verify the file is in `.github/workflows/`

## Next Improvements

- add linting with `ruff`
- add integration tests
- add a deployment job for a Linux server
- add rollback support
- add image vulnerability scanning
