
{{- if .Values.reset.enabled -}}
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: reset-webshell
spec:
  jobTemplate:
    metadata:
      name: reset-webshell
    spec:
      template:
        metadata:
          creationTimestamp: null
        spec:
          restartPolicy: OnFailure
          containers:
          - command:
            - kubectl
            - rollout
            - restart
            - deployment
            - webshell
            image: quay.io/bitnami/kubectl
            name: reset-webshell
          serviceAccount: reset-cronjob
  schedule: "{{ .Values.reset.schedule }}"

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: reset-cronjob


---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: reset-cronjob
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: reset-cronjob
subjects:
- kind: ServiceAccount
  name: reset-cronjob
  namespace: {{ .Release.Namespace }}

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: reset-cronjob
rules:
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - get
  - patch
  - update
{{- end -}}