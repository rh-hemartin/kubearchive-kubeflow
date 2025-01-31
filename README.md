# KubeArchive for KubeFlow

It needs at least Kubernetes 1.30, so you may need to update your `kind` version:


```
kind create cluster
bash install.sh

python -m venv venv
source venv/bin/activate
python -m pip install -r requirements.txt
bash run.sh
```
