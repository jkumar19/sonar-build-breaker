FROM alpine:3.11

RUN mkdir -p /apps/sonar \
    && apk add curl bash jq 

COPY SonarBuildBreaker.sh /apps/sonar/SonarBuildBreaker.sh

WORKDIR /apps/sonar

RUN ls -ltr /apps/sonar

ENTRYPOINT ["bash", "/apps/sonar/SonarBuildBreaker.sh"]
