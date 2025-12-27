FROM alpine:3.20
RUN apk add --no-cache autossh openssh-client netcat-openbsd jq

COPY run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]

