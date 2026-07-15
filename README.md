# GitHub Copilot OTel + Grafana

This repository demonstrates two ways to visualize GitHub Copilot OpenTelemetry traces in Grafana:

- Local setup with Docker Compose and Grafana Tempo (fastest to start)
- Azure setup with OpenTelemetry Collector, Application Insights, and Azure Managed Grafana

## Repository Paths

- `local-setup/`: Local-only stack (Tempo + Grafana)
- `azure-setup/`: Azure-provisioned stack (Collector + App Insights + Managed Grafana)

## Quick Navigation

- Local path guide: [local-setup/README.md](local-setup/README.md)
- Azure path guide: [azure-setup/README.md](azure-setup/README.md)

## Which Path To Use

- Use `local-setup` if you want to test quickly on a laptop with no Azure resources.
- Use `azure-setup` if you want team or production-style monitoring with centralized ingestion and governance.

## Prerequisites (General)

- VS Code with GitHub Copilot Chat
- Docker Desktop
- PowerShell (`pwsh`) for scripts

For Azure mode, also ensure you have Azure CLI (`az`) and required permissions.

## Notes

- This repo now ignores `.env` files to avoid committing credentials.
- Keep sample files like `.env.example` committed for onboarding.
