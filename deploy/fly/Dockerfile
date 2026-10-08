FROM hclonely/awa-helper:latest

USER root
RUN apk add --no-cache su-exec
COPY start.sh /start.sh
WORKDIR /usr/src/app/output
ENTRYPOINT ["/bin/sh", "/start.sh"]
CMD ["node", "index.js", "--manager"]
