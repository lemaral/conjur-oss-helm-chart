{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "conjur-oss.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "conjur-oss.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "conjur-oss.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate CA and end user certificate for NGINX
*/}}
{{- define "conjur-oss.ssl-cert-gen" -}}
{{- $altNames := .Values.ssl.altnames -}}
{{- $altNames := append $altNames (include "conjur-oss.fullname" .) -}}
{{- $altNames := append $altNames ( printf "%s.%s" (include "conjur-oss.fullname" .) .Release.Namespace ) -}}
{{- $altNames := append $altNames ( printf "%s.%s.svc" (include "conjur-oss.fullname" .) .Release.Namespace ) -}}
{{- $expiration := .Values.ssl.expiration | int -}}
{{- $ca := genCA "conjur-oss-ca" (.Values.ssl.expiration | int) -}}
{{- $cert := genSignedCert .Values.ssl.hostname nil $altNames $expiration $ca -}}
{{- $_ := set . "caCrt" ($ca.Cert | b64enc) }}
{{- $_ := set . "caKey" ($ca.Key | b64enc) }}
{{- $_ := set . "certCrt" ($cert.Cert | b64enc) }}
{{- $_ := set . "certKey" ($cert.Key | b64enc) }}
{{- end -}}
