{% from "jboss/map.jinja" import jboss_settings with context %}

java8_remove_permsize_param:
  file:
    - replace
    - name: {{ jboss_settings.jboss_home }}/bin/domain.conf 
    - pattern: '-XX:MaxPermSize=256m.'
    - repl: ''