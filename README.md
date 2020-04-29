# operations-helper

## Requirements
The following images must exist:
- cratekube/lifecycle-service:local
- cratekube/lifecycle-service:1.0.0
- cratekube/cloud-mgmt-service:1.0.0
- cratekube/cluster-mgmt-service:1.0.0

## Usage
```bash
./configureCluster.sh
```
Deploys the local tag of the `lifecycle-service`. Version `1.0.0` is what exists in GitHub `deployment.yml` files, however the **latest version** may be different. 

Visiting the `<host>:30000/swagger` brings you to the`lifecycle-service` swagger UI.

Visiting the `<host>:30001/swagger` brings you to the`cluster-mgmt-service` swagger UI.

Visiting the `<host>:30002/swagger` brings you to the`cloud-mgmt-service` swagger UI.