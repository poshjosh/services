# Repo: https://github.com/poshjosh/services
# @see https://hub.docker.com/_/maven
# ---------------
# Pull base image
# ---------------
FROM maven:3-alpine
# Speed up Maven a bit
# ---------------
ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
