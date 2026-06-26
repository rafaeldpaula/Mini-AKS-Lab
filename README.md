# TesteTecnico

Minimal .NET API used to practice endpoint design, persistence and cloud deployment concepts.

## API endpoints

- `POST /tasks` creates a task.
- `GET /tasks/{id}` returns a task by id.
- `GET /tasks` returns all tasks.
- `GET /healthz` returns the application health status and is used by Kubernetes probes.

Example request:

```bash
curl -X POST http://localhost:5256/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Study AKS","description":"Deploy this API to Azure Kubernetes Service"}'
```

## Running locally

```bash
dotnet run --project TesteTecnico/TesteTecnico.csproj
```

The local configuration uses SQLite through the `DefaultConnection` connection string.

## Running with Docker

```bash
docker build -t testetecnico:local .
docker run --rm -p 8080:8080 testetecnico:local
```

Then test:

```bash
curl http://localhost:8080/healthz
curl http://localhost:8080/tasks
```

## Deploying to AKS

The AKS infrastructure lives in [`infra/terraform`](infra/terraform). The Kubernetes manifest lives in [`k8s/testetecnico.yaml`](k8s/testetecnico.yaml).

The deployment flow is:

1. Provision AKS and ACR with Terraform.
2. Build the Docker image.
3. Push the image to ACR.
4. Apply the Kubernetes manifest.
5. Point the deployment to the image hosted in ACR.

See [`infra/terraform/README.md`](infra/terraform/README.md) for the full command sequence.
