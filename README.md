# TesteTecnico

`TesteTecnico` is a small .NET 9 Web API created to practice backend fundamentals and cloud deployment concepts using Azure Kubernetes Service (AKS).

The project starts from a simple task-management API and evolves it into a deployable application with Docker, Kubernetes manifests and Terraform infrastructure. The goal is not to build a complete production system yet, but to create a clean technical foundation that shows how an API can move from local development to a Kubernetes-based environment in Azure.

## Project goals

This repository is useful for practicing the following concepts:

- Building a minimal API with .NET 9.
- Organizing responsibilities between endpoints, services, repositories and persistence.
- Using Entity Framework Core with SQLite for a small persistence layer.
- Containerizing the API with Docker.
- Creating Kubernetes manifests for an application deployment.
- Provisioning AKS and Azure Container Registry (ACR) with Terraform.
- Understanding the deployment flow from source code to running workload in AKS.

## Current scope

The API currently manages task records. Each task has an id, title, description and status. The persistence layer uses SQLite, which is enough for local development and AKS learning, especially when combined with a Kubernetes persistent volume.

For a real production scenario, SQLite should be replaced by an external managed database such as Azure SQL, Azure Database for PostgreSQL or another service outside the application container. Keeping the database outside the pod makes the application easier to scale, update and recover.

## Architecture overview

The project follows a simple layered structure:

```text
Client
  |
  v
Minimal API endpoints
  |
  v
Task service
  |
  v
Repository
  |
  v
Entity Framework Core
  |
  v
SQLite database
```

The AKS deployment adds another infrastructure layer around the application:

```text
Source code
  |
  v
Docker image
  |
  v
Azure Container Registry
  |
  v
AKS Deployment
  |
  v
Kubernetes Service / LoadBalancer
  |
  v
Public HTTP endpoint
```

## Repository structure

```text
.
├── Dockerfile
├── README.md
├── TesteTecnico/
│   ├── Database/
│   ├── Entities/
│   ├── MapEndpoints/
│   ├── Repository/
│   ├── Services/
│   ├── Program.cs
│   └── TesteTecnico.csproj
├── infra/
│   └── terraform/
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── variables.tf
│       ├── terraform.tfvars.example
│       └── README.md
└── k8s/
    └── testetecnico.yaml
```

## API endpoints

| Method | Route | Description |
| --- | --- | --- |
| `POST` | `/tasks` | Creates a new task. |
| `GET` | `/tasks/{id}` | Returns a task by id. |
| `GET` | `/tasks` | Returns all created tasks. |
| `GET` | `/healthz` | Returns the application health status. Used by Kubernetes probes. |

Example request to create a task:

```bash
curl -X POST http://localhost:5256/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Study AKS","description":"Deploy this API to Azure Kubernetes Service"}'
```

Example request to check application health:

```bash
curl http://localhost:5256/healthz
```

## Running locally

Requirements:

- .NET 9 SDK

Run the API from the repository root:

```bash
dotnet run --project TesteTecnico/TesteTecnico.csproj
```

By default, the local profile exposes the application over HTTP on port `5256`. The application uses the `DefaultConnection` connection string from `appsettings.json` and stores data in a local SQLite database file.

## Running with Docker

Requirements:

- Docker

Build the image:

```bash
docker build -t testetecnico:local .
```

Run the container:

```bash
docker run --rm -p 8080:8080 testetecnico:local
```

Test the containerized API:

```bash
curl http://localhost:8080/healthz
curl http://localhost:8080/tasks
```

## AKS deployment model

The AKS setup is intentionally simple so the infrastructure remains easy to understand. Terraform provisions the Azure resources, Docker packages the application, ACR stores the image, and Kubernetes runs the workload.

The infrastructure lives in [`infra/terraform`](infra/terraform). It creates:

- Azure Resource Group.
- Azure Container Registry.
- Azure Kubernetes Service.
- AKS managed identity.
- `AcrPull` permission so AKS can pull images from ACR.

The Kubernetes manifest lives in [`k8s/testetecnico.yaml`](k8s/testetecnico.yaml). It defines:

- `Namespace` for isolation.
- `Deployment` for the API workload.
- `Service` of type `LoadBalancer` to expose the API.
- `PersistentVolumeClaim` to persist the SQLite file.
- Readiness and liveness probes using `/healthz`.
- Basic CPU and memory requests/limits.

## Deploying to AKS

The general deployment flow is:

1. Provision AKS and ACR with Terraform.
2. Build the Docker image.
3. Push the image to ACR.
4. Connect `kubectl` to the AKS cluster.
5. Apply the Kubernetes manifest.
6. Update the deployment image to use the ACR image.
7. Test the public endpoint exposed by the LoadBalancer service.

The full command sequence is documented in [`infra/terraform/README.md`](infra/terraform/README.md).

## Why `/healthz` exists

The `/healthz` endpoint gives Kubernetes a lightweight way to check whether the API process is alive and ready to receive traffic. The deployment uses it for both readiness and liveness probes.

Readiness tells Kubernetes when the pod can receive traffic. Liveness tells Kubernetes when the container should be restarted because it is no longer healthy.

## Important notes

This project is currently designed as a learning and technical-test project. The AKS structure is deliberately small, but it already touches important production concepts such as containerization, registry integration, Kubernetes deployment, health checks, persistent storage and infrastructure as code.

Before treating this as production-ready, the next improvements should be:

- Replace SQLite with a managed database.
- Add automated tests to the CI pipeline.
- Add GitHub Actions for build, test, Docker image push and AKS deployment.
- Add environment-specific configuration.
- Add observability with logs, metrics and traces.
- Add ingress and HTTPS instead of exposing the service directly as a LoadBalancer.

## Learning path suggested for this project

A good way to study this repository is to move in this order:

1. Understand the current API endpoints and service/repository flow.
2. Run the API locally with .NET.
3. Run the API locally with Docker.
4. Read the Kubernetes manifest and identify what each object does.
5. Provision AKS and ACR with Terraform.
6. Push the Docker image to ACR.
7. Deploy the application to AKS.
8. Replace one piece at a time with more production-like choices, starting with the database and deployment pipeline.
