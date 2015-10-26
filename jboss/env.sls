{% from "jboss/map.jinja" import jboss with context %}

# set JBOSS environment variables (ex: JBOSS_HOME)
{{ jboss.profileddir }}/jboss_env.sh:
  file.managed:
    - source: salt://jboss/files/jboss_env.sh
    - user: root
    - group: root
    - mode: 644
    - template: jinja