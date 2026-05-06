#!/bin/bash

echo "Deleting existing kind clusters..."
kind delete clusters --all

echo "Creating new kind cluster..."
kind create cluster --config ./k8s/kind/kind-config.yaml

echo "Installing ArgoCD in the cluster..."

REPO_URL=https://argoproj.github.io/argo-helm
CHART_NAME=argo-cd
RELEASE_NAME=argocd
NAMESPACE=argo-cd
VERSION=9.5.6

helm upgrade --install $RELEASE_NAME --repo $REPO_URL $CHART_NAME \
  --version $VERSION \
  --namespace $NAMESPACE \
  --create-namespace \
  -f k8s/argocd/custom-values.yaml



kubectl apply -f k8s/argocd/argocd-repo-creds-secret.yaml
kubectl apply -f k8s/argocd/argocd-project.yaml


kubectl apply -f argo-bootstrap/argo-app-bootstrap.yaml

echo "Waiting for ArgoCD server to be ready..."
echo "Run the command below to port-forward the ArgoCD server and access the UI at http://localhost:18080"

echo "kubectl port-forward service/argocd-server -n argo-cd  18080:443"