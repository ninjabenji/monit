FROM alpine
RUN apk add monit curl

RUN mkdir /etc/monit.d
COPY config/monitrc /etc/monitrc
COPY bin/entrypoint /usr/bin/entrypoint
COPY bin/monit_alert-actions /usr/bin/monit_alert-actions

ENTRYPOINT ["/usr/bin/entrypoint"]

