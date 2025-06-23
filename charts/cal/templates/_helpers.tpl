{{/*
Expand the name of the chart.
*/}}
{{- define "calcom.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "calcom.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "calcom.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "calcom.labels" -}}
helm.sh/chart: {{ include "calcom.chart" . }}
{{ include "calcom.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "calcom.selectorLabels" -}}
app.kubernetes.io/name: {{ include "calcom.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "calcom.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "calcom.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret to use
*/}}
{{- define "calcom.secretName" -}}
{{- if .Values.calcom.secrets.existingSecret }}
{{- .Values.calcom.secrets.existingSecret }}
{{- else }}
{{- include "calcom.fullname" . }}-secrets
{{- end }}
{{- end }}

{{/*
Create the database URL
*/}}
{{- define "calcom.databaseUrl" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "postgresql://%s:%s@%s-postgresql:%d/%s" .Values.postgresql.auth.username .Values.postgresql.auth.password .Release.Name (.Values.postgresql.primary.service.ports.postgresql | default 5432) .Values.postgresql.auth.database }}
{{- else if .Values.calcom.database.external }}
{{- printf "postgresql://%s:%s@%s:%d/%s" .Values.calcom.database.user .Values.calcom.database.password .Values.calcom.database.host (.Values.calcom.database.port | default 5432) .Values.calcom.database.name }}
{{- else }}
{{- required "Database configuration is required" "" }}
{{- end }}
{{- end }}

{{/*
Create the database direct URL
*/}}
{{- define "calcom.databaseDirectUrl" -}}
{{- if .Values.calcom.database.directUrl }}
{{- .Values.calcom.database.directUrl }}
{{- else }}
{{- include "calcom.databaseUrl" . }}
{{- end }}
{{- end }}

{{/*
Create the database host
*/}}
{{- define "calcom.databaseHost" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql:5432" .Release.Name }}
{{- else if .Values.calcom.database.external }}
{{- printf "%s:%d" .Values.calcom.database.host (.Values.calcom.database.port | default 5432) }}
{{- else }}
{{- required "Database host is required" "" }}
{{- end }}
{{- end }}