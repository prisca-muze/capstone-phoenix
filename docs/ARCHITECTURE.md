# Architecture

## Node Topology

```
Internet
    │
    ▼
AWS Security Group (80/443 open; 22+6443 admin-IP only; inter-node unrestricted)
    │
    ▼
VPC 10.0.0.0/16  Subnet 10.0.1.0/24  (eu-north-1)
    ├── control-plane  10.0.1.197  (k3s server, etcd, Argo CD, cert-manager, ingress-nginx)
    ├── worker-0       10.0.1.134  (k3s agent — workloads)
    └── worker-1       10.0.1.153  (k3s agent — workloads)

CNI: Calico v3.32.1 (enforces NetworkPolicy)
Runtime: containerd v2.3.2
k3s: v1.36.2
```

## Request Flow

```
DNS: taskapp.13.62.51.193.sslip.io  →  13.62.51.193 (control-plane externalIP)
  │
  ▼ :443  TLS terminated by ingress-nginx (cert from Let's Encrypt via cert-manager)
  │
  ├─ /api  →  backend Service :5000  →  backend Pods (2–6, HPA on CPU+mem)
  │                                         │
  │                                         ▼
  │                                    postgres Service (headless, DNS → pod IP)
  │                                         │
  │                                         ▼
  │                                    postgres-0 StatefulSet  (5Gi PVC, local-path)
  │
  └─ /     →  frontend Service :80  →  frontend Pods (2 replicas, nginx static)
```

## Single-Server Assumptions Fixed

| Core Requirement | Assumption it fixes |
|---|---|
| Postgres StatefulSet + PVC | Data on host disk — lost on reschedule |
| 2+ replicas + topologySpreadConstraints | One process, one node = one failure point |
| Migration Job (not entrypoint) | Single-replica migration race-free — breaks at 2+ replicas |
| HPA on backend | Manual scale on one box |
| RollingUpdate maxUnavailable=0 | docker restart = downtime |
| Liveness/Readiness probes | No health-aware routing |
| NetworkPolicy default-deny | Any pod reaches any other pod |
| PodDisruptionBudget | Node drain kills all replicas simultaneously |
| Ingress + TLS (cert-manager) | Manual nginx/certbot config on one host |
| Argo CD GitOps | Manual kubectl apply as deployment mechanism |

## GitOps Flow

```
git push → Argo CD polls repo (every 3 min) → applies diff → cluster matches HEAD
automated.prune=true   removes deleted resources
automated.selfHeal=true  reverts manual kubectl changes
```
