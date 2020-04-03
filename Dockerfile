# Repo: https://github.com/poshjosh/services
# @see https://hub.docker.com/_/maven
# ---------------
FROM maven:3-alpine
LABEL maintaner="posh.bc@gmail.com"
# Create and use non-root user
# ----------------------------
RUN addgroup -S poshjosh && adduser -S poshjosh -G poshjosh
USER poshjosh
# Speed up Maven a bit
# --------------------
ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
# Install project dependencies and keep sources
# ---------------------------------------------
# make source folder
# ------------------
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
# Install maven dependency packages (keep in image).
# Create a pre-packaged repository by using our pom.xml and settings file
# /usr/share/maven/ref/settings-docker.xml which is a settings file that changes
# the local repository to /usr/share/maven/ref/repository.
# Anything in /usr/share/maven/ref/ will be copied on container startup to the
# maven config folder referenced thus $MAVEN_CONFIG (default value = /root/.m2)
# ---------------
COPY pom.xml /usr/src/app
RUN mvn -B -f /usr/src/app/pom.xml -s /usr/share/maven/ref/settings-docker.xml dependency:resolve
# NOT APPLICABLE TO pom projects
# Copy other source files (keep in image) 
# ---------------------------------------
# COPY src /usr/src/app/src

