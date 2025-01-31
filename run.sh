#!/bin/bash

set -o errexit
set -o xtrace

trap 'kill $(jobs -p)' EXIT

kubectl apply -f kac.yaml

sleep 5

kubectl port-forward -n kubeflow svc/ml-pipeline-ui 8080:80 &
python greeting.py
python run.py

sleep 15

export PGPASSWORD=$(kubectl get -n kubearchive secret kubearchive-database-credentials -o jsonpath='{.data.DATABASE_PASSWORD}' | base64 --decode)
kubectl exec -n postgresql -i deployment/postgresql -- env PGPASSWORD=$PGPASSWORD psql -h localhost -U kubearchive kubearchive -c "SELECT kind, namespace, name FROM resource;"
