# GitOps Demo: SonarQube DCE on kind via ArgoCD

Demonstrates the GitOps pattern: ArgoCD watches this repo and keeps the cluster
in sync with what's committed here.

## Architecture

```
bootstrap/root-app.yaml   ← applied once by hand (the only manual step)
        │
        └── apps/          ← ArgoCD App-of-Apps; any YAML added here is auto-deployed
              ├── postgres.yaml        (Bitnami PostgreSQL)
              └── sonarqube-dce.yaml   (SonarQube DCE, 2 app nodes + 3 search nodes)
```

Each `Application` in `apps/` uses **multi-source**: the Helm chart comes from
its upstream chart repo, but the values come from `values/` in *this* Git repo.
Changing a value here → ArgoCD detects the diff → re-deploys automatically.

## Quick start

```bash
# 1. Create secrets (one-time, never committed to Git)
bash bootstrap/secrets.sh

# 2. Apply the root app – ArgoCD takes over from here
kubectl apply -f bootstrap/root-app.yaml

# 3. Watch ArgoCD sync
kubectl port-forward svc/argocd-server -n argocd 8080:443
# open https://localhost:8080  (admin / get password below)
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# 4. Access SonarQube once pods are Ready
kubectl port-forward svc/sonarqube-sonarqube-dce -n sonarqube-dce 9000:9000
# open http://localhost:9000  (admin / AdminAdmin_12$)
```

## Demo: self-healing

```bash
# Delete a SonarQube pod – ArgoCD recreates it within seconds
kubectl delete pod -n sonarqube-dce -l app=sonarqube-dce-app --wait=false
# Watch ArgoCD bring it back
```

## Demo: GitOps config change

Edit `values/sonarqube-dce.yaml`, commit and push → ArgoCD detects the change
and applies it automatically (automated sync is enabled).
