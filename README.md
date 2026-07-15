# GitHub Copilot OTel + Grafana

This repository demonstrates two ways to visualize GitHub Copilot OpenTelemetry traces in Grafana:

- Local setup with Docker Compose and Grafana Tempo (fastest to start)
- Azure setup with OpenTelemetry Collector, Application Insights, and Azure Managed Grafana

![Azure Setup Article Image](azure-setup/media/article-image.png)

## Article

[Monitoring GitHub Copilot at Scale with OpenTelemetry (OTLP) and Grafana | by Lior Yantovski | Jul, 2026 | Medium](https://medium.com/@lioryantovski/monitoring-github-copilot-at-scale-with-opentelemetry-otlp-and-grafana-6d011279e766?postPublishedType=repub)

## Important

**Important:** While this guide provides the foundational blueprints for local and Azure-native pipelines, API endpoints, schema mappings, and authentication scopes (especially regarding Azure's OTLP preview endpoints) are subject to change.

For advanced configurations, network hardening, or troubleshooting edge cases, always cross-reference your implementation with the **official documentation.**

Microsoft and GitHub official docs reference:

- [Monitor AI coding agents with Grafana | Microsoft Learn](https://learn.microsoft.com/en-us/azure/managed-grafana/grafana-opentelemetry-app-insights)
- [Ingest OTLP Data into Azure Monitor with OTel Collector - Azure Monitor | Microsoft Learn](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/opentelemetry-protocol-ingestion)
- [Collect and analyze OpenTelemetry data with Azure Monitor (Preview) - Azure Monitor | Microsoft Learn](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/collect-use-observability-data)
- [Enterprise-managed OpenTelemetry export for VS Code and CLI - GitHub Changelog](https://github.blog/changelog/2026-07-08-enterprise-managed-opentelemetry-export-for-vs-code-and-cli/)

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
