{% from "jboss/map.jinja" import jboss with context %}

{%- set jboss_domain_controller = salt['grains.get']('jboss_domain_controller', False) %}
{%- if jboss_domain_controller == true %}  

include:
  - jboss.service
  
add_oracle_driver_to_full_ha_profile:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c '/profile=full-ha/subsystem=datasources/jdbc-driver=oracle/:add(driver-module-name=com.oracle,driver-name=oracle,jdbc-compliant=true,driver-datasource-class-name=oracle.jdbc.OracleDriver)' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'
    - unless: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c '/profile=full-ha/subsystem=datasources/jdbc-driver=oracle/:read-resource(recursive-depth=0)' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'

{%- endif %}
