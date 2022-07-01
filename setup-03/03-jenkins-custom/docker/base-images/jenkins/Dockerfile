ARG parent_image
FROM ${parent_image} AS jenkins-base
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --verbose -f /usr/share/jenkins/ref/plugins.txt

#COPY jenkins.yaml /usr/share/jenkins/ref/
#ENV CASC_JENKINS_CONFIG /usr/share/jenkins/ref/jenkins.yaml

#COPY logging.properties /usr/share/jenkins/ref
#ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false"