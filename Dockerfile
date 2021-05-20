#monit will load all config files in /etc/monit.d/
#Swarm "configs" should be mapped directly into /etc/monit.d/
#Swarm "secrets" called monit_config_* will be symlinked into /etc/monit.d
#Curl needed by monit_alert-actions script

#Check monit_alert-actions script for required ENV Vars and Secrets

#SWARM SECRETS:
# - monit_config_*      (monit config file content, can have multiple)

#SWARM CONFIGS:
# Can be named anything ending .cfg, must be mapped into /etc/monit.d/

FROM alpine

RUN apk add monit curl

RUN mkdir /etc/monit.d
COPY config/monitrc /etc/monitrc
COPY bin/entrypoint /usr/bin/entrypoint
COPY bin/monit_alert-actions /usr/bin/monit_alert-actions

ENTRYPOINT ["/usr/bin/entrypoint"]

