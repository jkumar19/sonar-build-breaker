FROM alpine:3.23.2

RUN mkdir -p /apps/sonar \
    && apk add curl bash jq 

COPY SonarBuildBreaker.sh /apps/sonar/SonarBuildBreaker.sh

WORKDIR /apps/sonar

RUN ls -ltr /apps/sonar

ENTRYPOINT ["bash", "/apps/sonar/SonarBuildBreaker.sh"]
