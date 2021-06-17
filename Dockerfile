FROM alpine:3.12.7
RUN apk add monit curl

RUN mkdir /etc/monit.d
COPY config/monitrc /etc/monitrc
COPY bin/entrypoint /usr/bin/entrypoint
COPY bin/monit_alert-actions /usr/bin/monit_alert-actions
RUN chmod 600 /etc/monitrc

ENTRYPOINT ["/usr/bin/entrypoint"]

