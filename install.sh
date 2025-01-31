#!/bin/bash

set -o errexit
set -o xtrace

export PIPELINE_VERSION=2.3.0
kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=$PIPELINE_VERSION&timeout=90"
kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io
kubectl apply --kustomize="github.com/kubeflow/pipelines/manifests/kustomize/env/platform-agnostic?ref=${PIPELINE_VERSION}&timeout=90"
kubectl set -n kubeflow env deployment ml-pipeline-ui DISABLE_GKE_METADATA=true

kubectl apply -k karchive/deps
echo "Waiting a little for stuff to be up and running..."
kubectl wait -n cert-manager pod --all --for=condition=Ready --timeout=180s
kubectl wait -n knative-eventing pod --all --for=condition=Ready --timeout=180s

kubectl apply -f karchive/deps/postgresql.yaml

kubectl apply -k karchive/
kubectl wait -n kubearchive pod --all --for=condition=Ready --timeout=180s

export PGPASSWORD=$(kubectl get -n kubearchive secret kubearchive-database-credentials -o jsonpath='{.data.DATABASE_PASSWORD}' | base64 --decode)
cat karchive/kubearchive.sql | kubectl exec -n postgresql -i deployment/postgresql -- env PGPASSWORD=$PGPASSWORD psql -h localhost -U kubearchive kubearchive
