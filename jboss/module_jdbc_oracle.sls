{%- from "jboss/map.jinja" import jboss_settings with context %}

copy_oracle_jdbc_driver:
  file.copy:
    - name:  {{ jboss_settings.jboss_home }}/modules/com/oracle/main/{{ jboss_settings.jdbc_driver_oracle }}
    - source: {{ jboss_settings.oracle_client_home }}/lib/{{ jboss_settings.jdbc_driver_oracle }}
    - preserve: false
    - user: jboss
    - group: jboss
    - mode: 644
    - makedirs: True

configure_jboss_module_for_oracle_jdbc_driver:
  file:
    - managed
    - name: {{ jboss_settings.jboss_home }}/modules/com/oracle/main/module.xml
    - source: salt://jboss/files/module_jdbc_oracle.xml
    - user: jboss
    - group: jboss
    - mode: 644
    - template: jinja