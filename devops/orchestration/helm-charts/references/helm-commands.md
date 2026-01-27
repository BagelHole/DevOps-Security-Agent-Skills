# Helm Commands Reference

## Chart Management

```bash
# Create new chart
helm create mychart

# Lint chart
helm lint mychart/

# Package chart
helm package mychart/

# Template (render without installing)
helm template myrelease mychart/ --values values.yaml
```

## Repository

```bash
# Add repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add stable https://charts.helm.sh/stable

# Update repos
helm repo update

# Search
helm search repo nginx
helm search hub nginx
```

## Installation

```bash
# Install
helm install myrelease mychart/
helm install myrelease bitnami/nginx --namespace prod --create-namespace

# With values
helm install myrelease mychart/ -f values.yaml
helm install myrelease mychart/ --set image.tag=v1.0

# Dry run
helm install myrelease mychart/ --dry-run --debug

# Wait for completion
helm install myrelease mychart/ --wait --timeout 5m
```

## Upgrade & Rollback

```bash
# Upgrade
helm upgrade myrelease mychart/ -f values.yaml
helm upgrade --install myrelease mychart/  # Install or upgrade

# Rollback
helm rollback myrelease 1  # Rollback to revision 1
helm rollback myrelease    # Previous revision

# History
helm history myrelease
```

## Management

```bash
# List releases
helm list
helm list -A  # All namespaces
helm list --pending

# Get info
helm get values myrelease
helm get manifest myrelease
helm get all myrelease

# Status
helm status myrelease

# Uninstall
helm uninstall myrelease
helm uninstall myrelease --keep-history
```

## Chart Structure

```
mychart/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── charts/             # Dependencies
├── templates/
│   ├── NOTES.txt       # Post-install notes
│   ├── _helpers.tpl    # Template helpers
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── .helmignore
```

## Template Functions

```yaml
# Built-in functions
{{ .Values.image.tag | default "latest" }}
{{ .Release.Name | upper }}
{{ include "mychart.fullname" . }}

# Conditionals
{{- if .Values.ingress.enabled }}
# ingress config
{{- end }}

# Loops
{{- range .Values.hosts }}
- host: {{ . }}
{{- end }}
```
