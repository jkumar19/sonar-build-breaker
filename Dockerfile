FROM alpine:3.10

RUN mkdir -p /apps/sonar \
    && apk add curl bash jq 

COPY sonar-build-breaker.sh /apps/sonar/sonar-build-breaker.sh

WORKDIR /apps/sonar

ENTRYPOINT ["./SonarBuildBreaker.sh"]
