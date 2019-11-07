FROM zappi/kubectl:1.15.5

LABEL maintainer "Zappi Devops <devops@zappistore.com>"

COPY init.sh /init.sh

ENTRYPOINT ["./init.sh"]
