FROM alpine:3.10

RUN mkdir -p /apps/sonar \
    && apk add curl bash jq 

COPY SonarBuildBreaker.sh /apps/sonar/SonarBuildBreaker.sh

WORKDIR /apps/sonar

ENTRYPOINT ["./SonarBuildBreaker.sh"]
