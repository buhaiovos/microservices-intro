# microservices-intro
Microservices Intro program, pre-requisite for Kubernetes educational program: https://learn.epam.com/catalog/detailsPage?id=550944b4-72c9-4c2d-93ef-545b6e569f61

## Homework 2 Review guide

### Kubernetes setup

All manifests live in [`k8s-resources/`](k8s-resources). Everything namespaced goes to **`k8s-program-buhaiovos`**
(unique name, so it won't clash with your own `k8s-program` namespace when you run it).

| Component | Kind | Notes |
|---|---|---|
| `songs-postgres`, `resources-postgres` | StatefulSet + Service | Postgres 18; DBs `songs_db` / `resources_db` created by init SQL from ConfigMaps; credentials from Secrets |
| `songs-ms-deployment`, `resources-ms-deployment` | Deployment + NodePort Service | Images `songs-image:0.1`, `resources-image:0.1`; schema managed by Flyway |
| `hostpath` | StorageClass | `rancher.io/local-path` provisioner, used by StatefulSet volume claims |

Tested on Rancher Desktop (images built locally are visible to the cluster, no registry needed).

#### Quick start

```bash
./build-images.sh 0.1     # tag must match image tags in *-ms-deployment.yaml
./apply-k8s.sh
kubectl -n k8s-program-buhaiovos get pods
./teardown-k8s.sh         # clean up when done
```

### Helper scripts

| Script | What it does |
|---|---|
| `build-images.sh <version>` | For `resources-service` and `songs-service`: runs `./gradlew :<service>:build` if no jar is in `build/libs`, then builds `resources-image:<version>` / `songs-image:<version>`. Note: an existing (possibly stale) jar is reused — delete `build/libs` or run `./gradlew build` to rebuild. |
| `apply-k8s.sh [kubectl args]` | Applies manifests in dependency order: namespace → storage class → PV → PVC → config maps & secrets → services → stateful sets → deployments. Extra args go to `kubectl apply` (e.g. `--dry-run=server`). |
| `teardown-k8s.sh [-y] [kubectl args]` | Deletes everything in reverse order, incl. StatefulSet PVCs (DB data is wiped, so init SQL runs again on next apply). Asks for confirmation unless `-y`. Hostpath data of the `songs-volume` PV stays on the node. |

> Renaming the namespace: update `namespace:` and `*.<namespace>.svc.cluster.local` URLs in all manifests, plus `NAMESPACE` in `teardown-k8s.sh`.

### Commit convention

Each homework lives on its own branch (`homework-1`, `homework-2`, …).

| Prefix | Meaning | Review? |
|---|---|---|
| `subtask X.Y: …` | Implements subtask `X.Y` of the homework (e.g. `subtask 1.4: apply config maps and secrets`) | Yes — this is the assignment |
| `no-task: …` | Tooling / convenience changes not required by the assignment (scripts, renames) | Can be skipped |

Commits before `subtask 1.1` on `homework-2` predate this convention.
