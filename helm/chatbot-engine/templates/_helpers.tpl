{{- define "engine.name" -}}{{ .Chart.Name }}{{- end -}}

{{- define "engine.labels" -}}
app.kubernetes.io/name: {{ include "engine.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels include a "component" label. API and Redis pods must never share
a selector, otherwise the API Service could route requests to Redis.
*/}}
{{- define "engine.selector" -}}
app.kubernetes.io/name: {{ include "engine.name" .ctx }}
app.kubernetes.io/instance: {{ .ctx.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}
