## ✅ Folder Structure for Repository

```bash
Jenkins-Cluster-Using-Docker-Kubernetes/
├── README.md
├── jenkins-master/
│   ├── Dockerfile
├── jenkins-agent/
│   ├── Dockerfile
│   ├── entrypoint.sh
├── jenkins-k8s/
│   ├── master/
│   │   ├── jenkins-deployment.yaml
│   │   ├── jenkins-pv-pvc.yaml
│   │   ├── jenkins-service.yaml
├── images/
│   ├── (optional screenshots if you want to add)
```


# 🚀 Jenkins Cluster using Docker & Kubernetes (From Scratch)

> This project sets up a complete Jenkins Master-Agent architecture **from scratch** without using any prebuilt Jenkins images, fully containerized with Docker and deployed on Kubernetes.

---

## 📦 What You'll Learn

- Build Jenkins Master image manually using Ubuntu + WAR file
- Build Jenkins Agent image with Docker and SSH
- Deploy Jenkins Master on Kubernetes using Deployment, PV, PVC, and NodePort service
- Connect Jenkins Agents dynamically via Kubernetes Pod Templates
- Run a sample Jenkins Pipeline job

---

## 🛠️ Step 1: Jenkins Master Docker Image (From Scratch)

📁 Folder: `jenkins-master/`

### 📝 Dockerfile
```dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    git \
    curl \
    wget \
    gnupg2 \
    unzip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

ENV JENKINS_HOME=/var/jenkins_home
ENV JENKINS_PORT=8080

RUN useradd -m -d ${JENKINS_HOME} -s /bin/bash jenkins && \
    mkdir -p /usr/share/jenkins && \
    mkdir -p ${JENKINS_HOME} && \
    chown -R jenkins:jenkins ${JENKINS_HOME}

RUN wget -O /usr/share/jenkins/jenkins.war https://get.jenkins.io/war-stable/latest/jenkins.war

EXPOSE ${JENKINS_PORT}

USER jenkins
WORKDIR ${JENKINS_HOME}
ENTRYPOINT ["java", "-jar", "/usr/share/jenkins/jenkins.war"]
````

### 📦 Build & Push Image

```bash
docker build -t custom-jenkins-master .
docker tag custom-jenkins-master:latest your-dockerhub/custom-jenkins-master
docker push your-dockerhub/custom-jenkins-master
```

---

## 🤖 Step 2: Jenkins Agent Docker Image (From Scratch)

📁 Folder: `jenkins-agent/`

### 📝 Dockerfile

```dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    git \
    curl \
    wget \
    unzip \
    sudo \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://get.docker.com | sh

RUN useradd -m -s /bin/bash jenkins

ENV JENKINS_AGENT_HOME=/home/jenkins
ENV AGENT_WORKDIR=/home/jenkins/agent
ENV JENKINS_URL=http://jenkins-master:8080

WORKDIR ${AGENT_WORKDIR}
RUN mkdir -p ${AGENT_WORKDIR}
RUN chown -R jenkins:jenkins ${JENKINS_AGENT_HOME}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER jenkins
ENTRYPOINT ["/entrypoint.sh"]
```

### 📝 entrypoint.sh

```bash
#!/bin/bash

if [ ! -f agent.jar ]; then
  wget http://jenkins-master:8080/jnlpJars/agent.jar
fi

exec java -jar agent.jar \
  -jnlpUrl http://jenkins-master:8080/computer/${JENKINS_AGENT_NAME}/jenkins-agent.jnlp \
  -secret ${JENKINS_AGENT_SECRET} \
  -workDir ${AGENT_WORKDIR}
```

---

## ☸️ Step 3: Deploy Jenkins on Kubernetes

📁 Folder: `jenkins-k8s/master/`

### 🧱 Persistent Volume & Claim (`jenkins-pv-pvc.yaml`)

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-pv
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 5Gi
  hostPath:
    path: /data/jenkins
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

### 🧱 Jenkins Deployment (`jenkins-deployment.yaml`)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins
        image: your-dockerhub/custom-jenkins-master:latest
        ports:
        - containerPort: 8080
```

### 🧱 Jenkins Service (`jenkins-service.yaml`)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: jenkins-service
spec:
  type: NodePort
  selector:
    app: jenkins
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
      nodePort: 30080
```

### ✅ Deploy to Kubernetes

```bash
kubectl apply -f jenkins-pv-pvc.yaml
kubectl apply -f jenkins-deployment.yaml
kubectl apply -f jenkins-service.yaml
```

Then access Jenkins UI at:
**http\://<your-node-ip>:30080**

---

## 🔐 Unlock Jenkins

```bash
kubectl exec -it <jenkins-pod> -- cat /var/jenkins_home/secrets/initialAdminPassword
```

Paste the output on the Jenkins web UI and click `Install Suggested Plugins`.

---

## 📦 Step 4: Create Pipeline Job

### ➕ New Item → `first-pipeline` → Type: Pipeline

```groovy
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                echo 'Hello Abhijeet! Jenkins is up and running on Kubernetes!'
            }
        }
    }
}
```

---

## 🏁 Result

🎉 Jenkins is now successfully:

* Running inside Kubernetes
* Built from custom Docker images (not prebuilt)
* Supports pipeline jobs and agents inside Kubernetes pods

---

## 📎 Resources

* [Official Jenkins WAR](https://get.jenkins.io/war-stable/latest/jenkins.war)
* [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
* [Kubernetes Docs](https://kubernetes.io/docs/home/)

---

## 👨‍💻 Author

**Abhijeet Gadge**
📧 [abhijeetgadge100@gmail.com](mailto:abhijeetgadge100@gmail.com)
🔗 [LinkedIn](https://www.linkedin.com/in/abhijeetgadge/) • [GitHub](https://github.com/abhi-gadge1773)

---


