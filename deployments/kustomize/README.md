## Deploy to different namespaces
1. generate the sealed secrets for the namespace

```bash
kubeseal --format yaml --namespace newnamespace < app-secrets.yaml > app-postgress-secrets-sealed.yaml
kubeseal --format yaml --namespace newnamespace < signal-secrets.yaml > app-signal-secrets-sealed.yaml

mv *sealed.yaml kustomize/overlays/app1

```

2. Deploy to the new namespace
```bash
kubectl apply -k microsvc/overlays/app1
```

## Update Resource image
1. Modify the kustomization.yaml to update the image name:
```bash
# this is found int microsvc/overlays/app1-update-image
  images:
  - name: asia.gcr.io/hip-microservices-experiment-2/crud-demo-app@sha256:1d0d20effaf07fca9acbdf5b5d8330f2b917793ddfb72e9e81c3ae45d4bcf851 
    newName: nginx
    newTag: latest 
```

2. Deploy the new image
```bash
kubectl apply -k microsvc/overlays/app1-update-image
```

2. Install/upgrade the new image
```bash
helm install -f values.yaml demo-app --namespace=staging
helm upgrade <chart-name> -f values.yaml demo-app --namespace=staging
```

3. Revert back to previous image
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

# note this helm install will be result in a working install.  the configmaps need to be correctly set.  see step to update configmap 
```
## Update Secrets
as described in "Deploy to different namespaces"

## Update Configmap
This chart creates envFrom configmap.  The user will be able to update the values in the configmap from an external file. 
```bash
# create a config.properties file like so:
SPRING_DATASOURCE_URL: jdbc:postgresql://10.83.48.3:5432/postgres
SFX_SERVICE_NAME: {{ include "demo-app.fullname" . }}-svc
JAEGER_SERVICE_NAME: {{ include "demo-app.fullname" . }}-svc
JAEGER_PROPAGATION: b3

# run the helm install to use this config file
helm install demo-app --namespace=staging --set-file configmap=config.properties


```



