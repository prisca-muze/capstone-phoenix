# Runbook

## Provision from Zero

```bash
# 1. SSH key
ssh-keygen -t ed25519 -f ~/.ssh/capstone-phoenix -N ""

# 2. Fill terraform.tfvars (copy from .example, set my_ip=$(curl -s ifconfig.me)/32)
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars && vim terraform.tfvars

# 3. Provision
terraform init && terraform apply -auto-approve
terraform output   # note the IPs

# 4. Fill infra/ansible/inventory.ini with IPs from step 3

# 5. Run Ansible
cd infra/ansible
~/.ansible-venv/bin/ansible-playbook playbooks/site.yml

# 6. If kubeconfig.yml didn't finish, fetch manually:
ssh -i ~/.ssh/capstone-phoenix ubuntu@<CP_PUBLIC_IP> "sudo cat /etc/rancher/k3s/k3s.yaml" \
  | sed "s|127.0.0.1|<CP_PUBLIC_IP>|g" > ~/.kube/config && chmod 600 ~/.kube/config

# 7. Install Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.1/manifests/calico.yaml
kubectl wait --for=condition=Ready nodes --all --timeout=120s

# 8. Install ingress-nginx
kubectl apply --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.15.1/deploy/static/provider/cloud/deploy.yaml
kubectl patch svc ingress-nginx-controller -n ingress-nginx \
  --type='json' -p='[{"op":"add","path":"/spec/externalIPs","value":["<CP_PUBLIC_IP>"]}]'

# 9. Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.3/cert-manager.yaml

# 10. Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 11. Deploy app (or let Argo CD do it)
kubectl apply -f manifests/
kubectl apply -f gitops/application.yaml
```

---

## Daily: If Your IP Changed (ISP dynamic IP)

```bash
curl -s ifconfig.me   # new IP
# update my_ip in infra/terraform/terraform.tfvars
cd infra/terraform && terraform apply -auto-approve
```

---

## Scale

```bash
kubectl get hpa -n taskapp              # check current state
kubectl top pods -n taskapp             # CPU/mem per pod
# HPA auto-scales backend 2-6; manual override:
kubectl scale deployment backend -n taskapp --replicas=4
```

---

## Zero-Downtime Rollout

```bash
# 1. Update image tag in manifests/backend-deployment.yaml
# 2. git commit + push → Argo CD auto-syncs (maxUnavailable=0 guarantees no downtime)
# Monitor:
kubectl rollout status deployment/backend -n taskapp
```

---

## Roll Back

```bash
# GitOps (preferred): revert commit in git → Argo CD syncs
# Emergency kubectl:
kubectl rollout undo deployment/backend -n taskapp
```

---

## Recover: Dead Worker

```bash
kubectl get nodes                        # confirm NotReady
# Pods reschedule automatically within ~5 min via PDB + replica spread
# If node permanently dead:
kubectl delete node <node-name>
# Terraform: taint + replace or add new worker, re-run k3s_agents.yml
```

---

## Recover: Dead Backend Pod

```bash
# Kubernetes restarts automatically via liveness probe
kubectl describe pod <pod> -n taskapp   # see events
kubectl logs <pod> -n taskapp --previous
```

---

## Recover: Bad Migration

```bash
# Roll back backend image in manifests/ and push
# Delete failed Job so it re-runs on next sync:
kubectl delete job migration -n taskapp
# Manual downgrade if needed:
kubectl run migration-rollback -n taskapp --restart=Never \
  --image=ghcr.io/ts-a-devops/taskapp-backend:<prev-tag> \
  --env="DATABASE_HOST=postgres" \
  -- alembic downgrade -1
```

---

## Argo CD Access

```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo

# Port-forward UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open https://localhost:8080  (user: admin)
```

---

## Verify Data Survives Pod Kill (PVC proof)

```bash
kubectl exec -it postgres-0 -n taskapp -- psql -U taskapp -d taskapp -c "SELECT count(*) FROM tasks;"
kubectl delete pod postgres-0 -n taskapp
kubectl wait --for=condition=Ready pod/postgres-0 -n taskapp --timeout=60s
kubectl exec -it postgres-0 -n taskapp -- psql -U taskapp -d taskapp -c "SELECT count(*) FROM tasks;"
# Row count must be identical
```
