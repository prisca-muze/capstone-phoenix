# Cost

## Monthly Cost Estimate (eu-north-1, on-demand)

| Resource | Spec | Unit Price | Monthly |
|---|---|---|---|
| EC2 control-plane | t3.small, 730h | $0.0228/hr | ~$16.65 |
| EC2 worker-0 | t3.small, 730h | $0.0228/hr | ~$16.65 |
| EC2 worker-1 | t3.small, 730h | $0.0228/hr | ~$16.65 |
| EBS gp3 × 3 nodes | 20GB each | $0.0952/GB/mo | ~$5.71 |
| S3 tfstate bucket | < 1MB | ~$0.00 | ~$0.00 |
| DynamoDB lock table | PAY_PER_REQUEST | ~$0.00 | ~$0.00 |
| Data transfer out | ~1GB/mo | $0.09/GB | ~$0.09 |
| **Total** | | | **~$55.75/mo** |

## How to Cut It in Half

Switch all three nodes to **t3.micro Spot Instances** (~70% discount vs on-demand): compute drops to ~$7.50/mo, total ~$13/mo. For a real production setup: 1-year Reserved Instances on t3.small save ~40%, and moving Postgres to **RDS db.t4g.micro** (free tier eligible) removes the storage overhead from the cluster entirely.
