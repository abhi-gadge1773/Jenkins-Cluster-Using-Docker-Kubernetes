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
