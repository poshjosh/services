# Repo: https://github.com/poshjosh/services
# @see https://hub.docker.com/_/maven
# ---------------
# Pull base image
# ---------------
FROM maven:3-alpine
# ---------------
# Create and use non-root user
# ---------------
#RUN addgroup -S looseboxes && adduser -S poshjosh -G looseboxes
#USER looseboxes:poshjosh
# Above caused error: unable to find user looseboxes: no matching entries in passwd file
# ---------------
# Speed up Maven a bit
# ---------------
ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
# ---------------
# Install project dependencies and keep sources
# ---------------
# make source folder
# ---------------
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
# ---------------
# Install maven dependency packages (keep in image)
# ---------------
 COPY pom.xml /usr/src/app
# RUN mvn -B -f /usr/src/app/pom.xml -s /usr/share/maven/ref/settings-docker.xml dependency:resolve
RUN mvn -B -f /usr/src/app/pom.xml -s /usr/share/maven/ref/settings-docker.xml 
# ---------------
# Copy other source files (keep in image) - Not applicable to pom projects
# ---------------
# COPY src /usr/src/app/src
