{% from "jboss/map.jinja" import jboss with context %}

java8_remove_permsize_param:
  file:
    - replace
    - name: {{ jboss.jboss_home }}/bin/domain.conf 
    - pattern: '-XX:MaxPermSize=256m.'
    - repl: ''