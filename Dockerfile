FROM alpine:latest

# Version https://github.com/aws/aws-cli/releases
ENV AWS_CLI_VERSION 1.15.55

RUN apk --no-cache update && \
    apk --no-cache add \
    python \
    py-pip \
    groff \
    less \
    mailcap \
    jq && \
    pip --no-cache-dir install --upgrade awscli==${AWS_CLI_VERSION} && \
    apk --purge del py-pip && \
    rm /var/cache/apk/*

VOLUME /root/.aws
VOLUME /aws

WORKDIR /aws

CMD ["aws"]