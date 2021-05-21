# monit
A simple docker container (based on Alpine) hosting the [monit](https://mmonit.com/monit/) monitoring app plus an "alert-actions" script containing actions that can be called from monit monitors.
It is intended to be used with docker swarm but could be used with docker run (secrets and configs could not be used but configs could be mapped into /etc/monit.d with a mount instead)

## The Build
The default /etc/monitrc config file is modified to do nothing but include /etc/monit.d/*.cfg

## The Config
You MUST pass in the monit config via either a swarm secret, a swarm config or a config file mapped directly into the container.

## Swarm Configs
Create any non sensitive config as swarm config(s) (must end in .cfg, at least after mapping if not before) and map directly into /etc/monit.d/

## Swarm Secrets
Create any sensitive config as swarm secrets named "monit_config_*". The entrypoint script will create symlinks in /etc/monit.d/ to all secrets following the naming convention.

## Alert Actions
Check the bin/monit_alert-actions script for the environment variables and/or secrets required by each available alert action

## Example
my_monit.cfg
```
set daemon  30
set log syslog

set httpd port 2812 and
    use address localhost
    allow localhost
    allow admin:monit

set alert you@yourdomain.com
set mailserver 	smtp.yourdomain.com
    port 587
    using SSL
    username 'USER'
    password 'PASSWORD'

set mail-format {
    from: Monit <monit@yourdomain.com>
    reply-to: you@yourdomain.com
    subject: MONIT ALERT: $SERVICE - $EVENT
    message:
SERVICE: $SERVICE
EVENT: $EVENT
DATE: $DATE

DESCRIPTION: $DESCRIPTION
 }

check host 'Ping Google'  address google.com every 10 cycles
  if failed ping4
    count 3
    size 32
    timeout 2 seconds
  then exec "/usr/bin/monit_alert-actions lox24-sms"
```

my_swarm.yaml
```yaml
version: "3.3"

secrets:
  monit_config_main:
    external: true
  monit_sms_gw_client:
    external: true
  monit_sms_gw_token:
    external: true
  monit_sms_number:
    external: true
networks:
  swarm-primary:
services:
  monit:
    image: ninjabenji/monit
    hostname: my-monit-host
    networks:
      - swarm-primary
    environment:
      - MONIT_SMS_SENDER=MonitAlert
      - MONIT_SMS_PRIORITY=direct
    secrets:
      - monit_config_main
      - monit_sms_gw_client
      - monit_sms_gw_token
      - monit_sms_number
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 60s
```

Create the required config via swarm secrets/configs and test
```bash
#Create the required config
printf '123456' | docker secret create monit_sms_gw_client -
printf '123abc456def789' | docker secret create monit_sms_gw_token -
printf '+4470000000000' | docker secret create monit_sms_number -
docker secret create monit_config_main my_monit.cfg

#Fire it up
docker stack deploy --compose-file my_swarm.yaml MYSWARM

#Check the logs
docker service logs MYSWARM_monit
```

