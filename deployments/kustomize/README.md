## Directory Structure and Layout
```bash
microsvc/
├── base
│   ├── app-configmap.yaml
│   ├── app-deployment.yaml
│   ├── app-service.yaml
│   └── kustomization.yaml
└── overlays
    ├── app1
    │   ├── app-postgress-secrets-sealed.yaml
    │   ├── app-signal-secrets-sealed.yaml
    │   ├── kustomization.yaml
    │   └── namespace.yaml
    ├── app1-revert-image
    │   └── kustomization.yaml
    ├── app1-update-configmap
    │   ├── app-cm-patch.yaml
    │   └── kustomization.yaml
    ├── app1-update-image
    │   └── kustomization.yaml
    ├── app1-update-resource
    │   ├── app-patches.yaml
    │   └── kustomization.yaml
    └── app1-update-secrets
        ├── app-postgress-secrets-sealed.yaml
        ├── app-signal-secrets-sealed.yaml
        └── kustomization.yaml
```
for simplicity the demnonstration for the various modifications have been added in as "*-updates-*" which in turn uses app1 as the base.

## Deploy to different namespaces
1. generate the sealed secrets for the namespace

```bash
kubeseal --format yaml --namespace newnamespace < app-secrets.yaml > app-postgress-secrets-sealed.yaml
kubeseal --format yaml --namespace newnamespace < signal-secrets.yaml > app-signal-secrets-sealed.yaml

mv *sealed.yaml kustomize/overlays/app1

```

2. Deploy to the cluster
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

3. Revert back to previous image
```bash
kubectl apply -k microsvc/overlays/app1-revert-image
```

## Update Resources
Modify resources by adding in a patch

```bash
# app-patches.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: crud-app-demo-1
  name: crud-app-demo-1-v1
spec:
  template:
    spec:
      containers:
      - name: crud-app-demo-1
        resources:
          requests:
            memory: "1024Mi"
            cpu: "1024m"
          limits:
            memory: "2048Mi"
            cpu: "1024m"

# kustomization.yaml
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization
  namespace: staging
  commonLabels:
    app: crud-staging-app1
    env: staging

  bases:
  - ../app1/

  patchesStrategicMerge:
  - app-patches.yaml 

# deploy to the cluster
kubectl apply -k microsvc/overlays/app1-update-resource

```

## Update Secrets
Repeat the step to deploy to a different namespace with the following modification to kustomization.yaml 
```bash
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization
  namespace: staging
  commonLabels:
    app: crud-staging-app1
    env: staging
  patchesStrategicMerge:
  - app-postgress-secrets-sealed.yaml
  - app-signal-secrets-sealed.yaml

  bases:
  - ../app1

# deploy to the cluster
kubectl apply -k microsvc/overlays/app1-update-secrets

```
## Update configmaps
patches can once again be used to update or modify the configmaps
```bash
# app-cm-patch.yaml:
apiVersion: v1
kind: ConfigMap
metadata:
  name: crud-app-demo-1-config
  labels:
    app: crud-app-demo-1
data:
  SPRING_DATASOURCE_URL: jdbc:postgresql://10.83.48.3:5432/postgres
  SFX_SERVICE_NAME: crud-app-demo-1
  JAEGER_SERVICE_NAME: crud-app-demo-1
  JAEGER_PROPAGATION: b3
  TEST_ENV: "this is a patch"

  # kustomization.yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization
  namespace: staging
  commonLabels:
    app: crud-staging-app1
    env: staging

  bases:
  - ../app1/

  patchesStrategicMerge:
  - app-cm-patch.yaml 

# deploy to the cluster
kubectl apply -k microsvc/overlays/app1-update-configmap
```