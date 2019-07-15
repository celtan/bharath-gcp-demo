## Deploy to different namespaces
1. generate the sealed secrets for the namespace

```bash
kubeseal --format yaml --namespace newnamespace < app-secrets.yaml > app-postgress-secrets-sealed.yaml
kubeseal --format yaml --namespace newnamespace < signal-secrets.yaml > app-signal-secrets-sealed.yaml

mkdir secrets
mv *.yaml secrets

```
2. Deploy secrets to the namespace
```
kubectl apply -f secrets -n staging

```

3. Install to the new namespace
```bash
helm install demo-app --namespace=staging

```

## Update Resource image
1. create a new values.yaml file for the parameter like so:
```
image:
  repository: asia.gcr.io/hip-microservices-experiment-2/crud-demo-app@sha256
  tag: 1d0d20effaf07fca9acbdf5b5d8330f2b917793ddfb72e9e81c3ae45d4bcf851
  pullPolicy: IfNotPresent
```
Note: this setting will overwrite the setting set in the values.yaml of the chart

2. Install/upgrade the new image
```bash
helm install -f values.yaml demo-app --namespace=staging
helm upgrade <chart-name> -f values.yaml demo-app --namespace=staging

```

## Update Resources
1. create a new values.yaml with the required parameters to be changed; an example:
```bash
resources:
  requests:
    memory: "1536Mi"
    cpu: "512m"
  limits:
    memory: "2048Mi"
    cpu: "512m" 

```
2. Install/upgrade the helm chart with the modified parameter
```bash
helm install -f values.yaml demo-app --namespace=staging
helm upgrade <chart-name> -f values.yaml demo-app --namespace=staging
```
## Update Secrets
as described in "Deploy to different namespaces"

## Update Configmap
```bash


```

