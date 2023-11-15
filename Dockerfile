FROM --platform="${TARGETPLATFORM}" alpine:latest
LABEL maintainer="mrProper-666 <mrproper.aka.dax@gmail.com>"

WORKDIR /tmp
ARG TARGETPLATFORM
ARG TAG
COPY xray.sh "${WORKDIR}"/xray.sh

RUN set -ex \
    && apk add --no-cache ca-certificates jq \
    && mkdir -p /etc/xray /usr/local/share/xray /var/log/xray  \
    && ln -sf /dev/stdout /var/log/xray/access.log \
    && ln -sf /dev/stderr /var/log/xray/error.log \
    && chmod +x "${WORKDIR}"/xray.sh \
    && "${WORKDIR}"/xray.sh "${TARGETPLATFORM}"

ENTRYPOINT ["/usr/bin/xray", "run", "-config", "/etc/xray/config.json"]
