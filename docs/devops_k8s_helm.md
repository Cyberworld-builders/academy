# Learning Helm Charts

## Example
Demonstrate walking through a basic helm chart usage.      

This is probably a good example:

[Youtube Video - _How to create Helm Charts - The Ultimate Guide_](https://youtu.be/jUYNS90nq8U?si=PgWttWPonRH-ZPeg)

[Github Repo - `devopsjourney1/helm-webapp`](https://github.com/devopsjourney1/helm-webapp)

## Notes
- Found a good, quick, simple, straightforward walkthrough off of Youtube that has a companion repo on Github. 
- Started this markdown doc in `docs/devops_k8s_helm.md` to log my progress.
- Created a folder in `devops-k8s-helm-test1/` to store my work. The folder name follows the same convention as the doc. This convention keeps the folder structure clean and simple while mapping out how a more complex structure might look in the future as things grow in complexity and the amount of content increases.
- Cloned the repo so I can conveniently scan and search the example code with my IDE as well as make it conversational with an LLM.
- generated scaffolding with `helm create webapp1`
- analyzed the scaffolding
- created a `values.yaml` file from scratch to learn and for practice
- deleted the templates from scaffolding and copied the ones from the example
- authenticated with my development cluster in the cloud
- install the example chart to my test project (what i'm about to do now) using the command `helm install mywebapp-release webapp1/`
> (***Backing up for a minute...***)
- setting up minikube for local development so i can iterate faster and learn from the ground up
- 

## Local Setup

### Minikube

### Kubectl
```sh
brew install kubectl
```

I already have kubectl. Moving on.

### Minikube
```sh
brew install minikube
```

Make sure Docker Desktop is running.

### Start it up
```sh
minikube start
```

## First Helm Chart

### Create a Chart
```sh
helm create my-nginx
```

## Test 1

### myapp1

At this stage, the entire codebase is simple enough to share with and LLM and ask more interactive type questions than what the video content alone can provide. 

#### Chart
```yaml
# Chart.yaml
apiVersion: v2
name: webapp1
description: A Helm chart for Kubernetes

# A chart can be either an 'application' or a 'library' chart.
#
# Application charts are a collection of templates that can be packaged into versioned archives
# to be deployed.
#
# Library charts provide useful utilities or functions for the chart developer. They're included as
# a dependency of application charts to inject those utilities and functions into the rendering
# pipeline. Library charts do not define any templates and therefore cannot be deployed.
type: application

# This is the chart version. This version number should be incremented each time you make changes
# to the chart and its templates, including the app version.
# Versions are expected to follow Semantic Versioning (https://semver.org/)
version: 0.1.0

# This is the version number of the application being deployed. This version number should be
# incremented each time you make changes to the application. Versions are not expected to
# follow Semantic Versioning. They should reflect the version the application is using.
# It is recommended to use it with quotes.
appVersion: "1.16.0"
```

#### Values
```yaml
# values.yaml

```

#### Deployment
```yaml
templates/deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: mydeployment
  namespace: default
  labels:
    app: mywebapp
spec:
  replicas: 5
  selector:
    matchLabels:
      app: mywebapp
      tier: frontend
  template:
    metadata:
      labels:
        app: mywebapp
        tier: frontend
    spec: # Pod spec
      containers:
      - name: mycontainer
        image: devopsjourney1/mywebapp:latest
        ports:
        - containerPort: 80
        envFrom:
        - configMapRef:
            name: myconfigmapv1.0
        resources:
          requests:
            memory: "16Mi" 
            cpu: "50m"    # 50 milli cores (1/20 CPU)
          limits:
            memory: "128Mi" # 128 mebibytes 
            cpu: "100m"
```

#### Service
```yaml
# templates/service.yaml

apiVersion: v1
kind: Service
metadata:
  name: mywebapp
  namespace: default
  labels:
    app: mywebapp
spec:
  ports:
  - port: 80
    protocol: TCP
    name: flask
  selector:
    app: mywebapp
    tier: frontend
  type: NodePort
```
#### Configmap
```yaml
# templates/configmap.yaml

kind: ConfigMap 
apiVersion: v1 
metadata:
  name: myconfigmapv1.0
  namespace: default
data:
  BG_COLOR: '#12181b'
  FONT_COLOR: '#FFFFFF'
  CUSTOM_HEADER: 'Customized with a configmap!'
```
## Here it is all together

### Chart
```yaml
# Chart.yaml

apiVersion: v2
name: webapp
description: A Helm chart for Kubernetes

# A chart can be either an 'application' or a 'library' chart.
#
# Application charts are a collection of templates that can be packaged into versioned archives
# to be deployed.
#
# Library charts provide useful utilities or functions for the chart developer. They're included as
# a dependency of application charts to inject those utilities and functions into the rendering
# pipeline. Library charts do not define any templates and therefore cannot be deployed.
type: application

# This is the chart version. This version number should be incremented each time you make changes
# to the chart and its templates, including the app version.
# Versions are expected to follow Semantic Versioning (https://semver.org/)
version: 0.1.0

# This is the version number of the application being deployed. This version number should be
# incremented each time you make changes to the application. Versions are not expected to
# follow Semantic Versioning. They should reflect the version the application is using.
# It is recommended to use it with quotes.
appVersion: "1.16.0"
```

### Values
```yaml
# values.yaml



appName: myhelmapp

port: 80

namespace: default

configmap:
  name: myhelmapp-configmap-v1
  data:
    CUSTOM_HEADER: 'This app was deployed with helm!'

image:
  name: devopsjourney1/mywebapp
  tag: latest
```

### Dev Values
```yaml
# values-dev.yaml

namespace: dev

configmap:
  data:
    CUSTOM_HEADER: 'This is on the DEV environment!'
```

### Prod Values
```yaml
# values-prod.yaml

namespace: prod

configmap:
  data:
    CUSTOM_HEADER: 'This is on the PROD environment!'
```

### Notes
```txt
# templates/NOTES.txt

servicename=$(k get service -l "app={{ .Values.appName }}" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace {{ .Values.namespace}} port-forward service/{{ .Values.appName }} 8888:80
```

### Config Map
```yaml
# templates/configmap.yaml

kind: ConfigMap 
apiVersion: v1 
metadata:
  name: {{ .Values.configmap.name }}
  namespace: {{ .Values.namespace }}
data:
  BG_COLOR: '#12181b'
  FONT_COLOR: '#FFFFFF'
  CUSTOM_HEADER: {{ .Values.configmap.data.CUSTOM_HEADER }}
```

### Deployment
```yaml
# templates/deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.appName }}
  namespace: {{ .Values.namespace }}
  labels:
    app: {{ .Values.appName }}
spec:
  replicas: 5
  selector:
    matchLabels:
      app: {{ .Values.appName }}
      tier: frontend
  template:
    metadata:
      labels:
        app: {{ .Values.appName }}
        tier: frontend
    spec: # Pod spec
      containers:
      - name: mycontainer
        image: "{{ .Values.image.name }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: 80
        envFrom:
        - configMapRef:
            name: {{ .Values.configmap.name }}
        resources:
          requests:
            memory: "16Mi" 
            cpu: "50m"    # 50 milli cores (1/20 CPU)
          limits:
            memory: "128Mi" # 128 mebibytes 
            cpu: "100m"
```

### Service
```yaml
# templates/service.yaml

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.appName }}
  namespace: {{ .Values.namespace }}
  labels:
    app: {{ .Values.appName }}
spec:
  ports:
  - port: 80
    protocol: TCP
    name: flask
  selector:
    app: {{ .Values.appName }}
    tier: frontend
  type: LoadBalancer
```