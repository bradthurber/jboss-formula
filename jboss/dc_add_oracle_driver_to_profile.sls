{%- set jboss_domain_controller = salt['grains.get']('jboss_domain_controller', 'False') %}
{%- if 'jboss-domain-controller' %}  

{% from "jboss/map.jinja" import jboss_settings with context %}

include:
  - jboss.service
  
add_oracle_driver_to_full_ha_profile:
  cmd.run:
    - name: {{ jboss_settings.jboss_home }}/bin/jboss-cli.sh -c '/profile=full-ha/subsystem=datasources/jdbc-driver=oracle/:add(driver-module-name=com.oracle,driver-name=oracle,jdbc-compliant=true,driver-datasource-class-name=oracle.jdbc.OracleDriver)' --user='{{ jboss_settings.admin_account.username }}' --password='{{ jboss_settings.admin_account.password }}'
    - unless: {{ jboss_settings.jboss_home }}/bin/jboss-cli.sh -c '/profile=full-ha/subsystem=datasources/jdbc-driver=oracle/:read-resource(recursive-depth=0)' --user='{{ jboss_settings.admin_account.username }}' --password='{{ jboss_settings.admin_account.password }}'

{%- endif %}
