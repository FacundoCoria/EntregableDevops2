{{- define "pedidos.base" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 48 | trimSuffix "-" -}}
{{- end -}}
