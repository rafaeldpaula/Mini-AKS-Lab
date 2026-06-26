# AKS infrastructure

This folder provisions the Azure resources needed to run the `TesteTecnico` API on AKS.

It creates:

- Azure Resource Group
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS)
- `AcrPull` role assignment so AKS can pull images from ACR

The cluster is intentionally small because this project is useful for learning and technical-test practice.

## Prerequisites

Install and authenticate the following tools:

- Azure CLI
- Terraform
- Docker
- kubectl

```bash
az login
az account set --subscription "<subscription-id>"
```

## Provision the infrastructure

From the repository root:

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -out main.tfplan
terraform apply main.tfplan
cd ../..
```

## Build and push the Docker image

```bash
ACR_NAME=$(terraform -chdir=infra/terraform output -raw acr_name)
ACR_LOGIN_SERVER=$(terraform -chdir=infra/terraform output -raw acr_login_server)

az acr login --name $ACR_NAME

docker build -t $ACR_LOGIN_SERVER/testetecnico:latest .
docker push $ACR_LOGIN_SERVER/testetecnico:latest
```

## Connect kubectl to AKS

```bash
RESOURCE_GROUP=$(terraform -chdir=infra/terraform output -raw resource_group_name)
AKS_NAME=$(terraform -chdir=infra/terraform output -raw aks_cluster_name)

az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --overwrite-existing
```

## Deploy the application

```bash
kubectl apply -f k8s/testetecnico.yaml
kubectl set image deployment/testetecnico testetecnico=$ACR_LOGIN_SERVER/testetecnico:latest -n testetecnico
kubectl rollout status deployment/testetecnico -n testetecnico
```

## Test the API

```bash
kubectl get service testetecnico -n testetecnico
```

After the external IP is assigned:

```bash
curl http://<external-ip>/healthz
curl http://<external-ip>/tasks
```

## Notes

The current project uses SQLite. For AKS study, the manifest mounts a small persistent volume at `/app/data` and overrides the connection string with `ConnectionStrings__DefaultConnection=Data Source=/app/data/testeTecnico.db`.

That is fine for learning, but a production AKS setup should move persistence to a managed database such as Azure SQL, PostgreSQL, or another external data service.
