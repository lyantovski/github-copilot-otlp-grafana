<#
.SYNOPSIS
Starts the local OpenTelemetry Collector in non-preview or preview mode.

.DESCRIPTION
This script selects one of the two collector YAML files by setting OTEL_CONFIG_FILE,
then runs docker compose for azure-setup/collector/docker-compose.yml.

.PARAMETER Mode
Collector mode to run.
- nonpreview: Uses otel-collector-config.yaml (connection string exporter path)
- preview: Uses otel-collector-config-otlp-preview.yaml (native OTLP + Entra auth path)

.PARAMETER NoRecreate
If provided, omits --force-recreate from docker compose up.

.PARAMETER ValidateOnly
If provided, validates required .env settings for the selected mode and exits without starting or restarting containers.

.EXAMPLE
./azure-setup/scripts/start-collector.ps1 -Mode nonpreview

.EXAMPLE
./azure-setup/scripts/start-collector.ps1 -Mode preview

.EXAMPLE
./azure-setup/scripts/start-collector.ps1 -Mode preview -NoRecreate

.EXAMPLE
./azure-setup/scripts/start-collector.ps1 -Mode preview -ValidateOnly
#>
param(
  [ValidateSet('nonpreview', 'preview')]
  [string]$Mode = 'nonpreview',

  [switch]$NoRecreate,

  [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'

function Require-Command {
  param([string]$Name)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Required command '$Name' was not found in PATH."
  }
}

function Read-EnvFile {
  param([string]$Path)

  $result = @{}
  foreach ($line in Get-Content $Path) {
    $trimmed = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
    if ($trimmed.StartsWith('#')) { continue }
    if (-not $trimmed.Contains('=')) { continue }

    $parts = $trimmed.Split('=', 2)
    $key = $parts[0].Trim()
    $value = $parts[1].Trim()
    if (-not [string]::IsNullOrWhiteSpace($key)) {
      $result[$key] = $value
    }
  }

  return $result
}

function Validate-EnvForMode {
  param(
    [string]$Mode,
    [hashtable]$EnvMap
  )

  $required = if ($Mode -eq 'preview') {
    @(
      'AZURE_MONITOR_TRACES_ENDPOINT',
      'AZURE_MONITOR_LOGS_ENDPOINT',
      'AZURE_MONITOR_METRICS_ENDPOINT',
      'AZURE_TENANT_ID',
      'AZURE_CLIENT_ID',
      'AZURE_CLIENT_SECRET'
    )
  }
  else {
    @('APPINSIGHTS_CONNECTION_STRING')
  }

  $missing = @()
  foreach ($key in $required) {
    if (-not $EnvMap.ContainsKey($key) -or [string]::IsNullOrWhiteSpace($EnvMap[$key])) {
      $missing += $key
    }
  }

  if ($missing.Count -gt 0) {
    Write-Warning "Missing required .env values for mode '$Mode':"
    foreach ($m in $missing) {
      Write-Warning "  - $m"
    }
    Write-Warning "Update azure-setup/collector/.env and rerun."
    throw "Cannot start collector: required .env values are missing."
  }

  if (-not $EnvMap.ContainsKey('COPILOT_USER_EMAIL') -or [string]::IsNullOrWhiteSpace($EnvMap['COPILOT_USER_EMAIL'])) {
    Write-Host "Note: COPILOT_USER_EMAIL is not set. Telemetry will be exported without a stamped user identity attribute."
  }
}

Require-Command 'docker'

$composeFile = 'azure-setup/collector/docker-compose.yml'
$envFile = 'azure-setup/collector/.env'

if (-not (Test-Path $envFile)) {
  throw "Missing $envFile. Create it from azure-setup/collector/.env.example first."
}

$envMap = Read-EnvFile -Path $envFile
Validate-EnvForMode -Mode $Mode -EnvMap $envMap

if ($ValidateOnly.IsPresent) {
  Write-Host "Validation passed for mode: $Mode"
  Write-Host "No container changes were made (ValidateOnly)."
  exit 0
}

$configFile = if ($Mode -eq 'preview') {
  'otel-collector-config-otlp-preview.yaml'
} else {
  'otel-collector-config.yaml'
}

Write-Host "Starting collector in mode: $Mode"
Write-Host "Using config: $configFile"

$env:OTEL_CONFIG_FILE = $configFile

$upArgs = @(
  'compose',
  '--env-file', $envFile,
  '-f', $composeFile,
  'up',
  '-d'
)

if (-not $NoRecreate.IsPresent) {
  $upArgs += '--force-recreate'
}

docker @upArgs

Write-Host ""
Write-Host 'Collector started. Validation commands:'
Write-Host '  docker ps --filter "name=otel-collector"'
Write-Host '  docker exec otel-collector printenv OTEL_CONFIG_FILE'
Write-Host '  docker logs --tail=100 otel-collector'
