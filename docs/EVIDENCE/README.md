# Evidence

Screenshots and logs proving each graded requirement. Capture these before submission.

| File | Proves |
|---|---|
| `kubectl-get-nodes.txt` | 3 Ready nodes from local machine |
| `pods-spread.txt` | Backend/frontend pods on different nodes (`kubectl get pods -n taskapp -o wide`) |
| `tls-cert.txt` | Valid Let's Encrypt cert (`curl -vI https://taskapp.13.62.51.193.sslip.io`) |
| `data-survives-pod-kill.txt` | Postgres row count before + after `kubectl delete pod postgres-0` |
| `zero-downtime-rollout.txt` | Unbroken 200s during rolling deploy (hey/wrk output) |
| `hpa-scaling.txt` | `kubectl get hpa -n taskapp -w` during load test |
| `argocd-synced.png` | Argo CD UI showing app Synced + Healthy |
| `failover-demo.txt` | Node drain + pod reschedule logs |
