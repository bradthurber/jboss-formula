{% from "jboss/map.jinja" import jboss with context %}

{%- set jboss_domain_controller = salt['grains.get']('jboss_domain_controller', False) %}
{%- if jboss_domain_controller == true %}  

{%- if "jboss_ldap_configured" not in grains or grains["jboss_ldap_configured"] != true %}
# JBoss not configured for ldap - so let's do it now

include:
  - jboss

# copy the .cli file we want to run to to host
dc_configure_ldap.cli:
  file.managed:
    - name: {{ jboss.cli_file_temp_dir }}/dc_configure_ldap.cli
    - source: salt://jboss/files/dc_configure_ldap.cli
    - user: {{ jboss.jboss_user }}
    - group: {{ jboss.jboss_user }}
    - mode: 644
    - template: jinja
    - unless: grep "{{ jboss.ldap.server_hostname }}" {{ jboss.jboss_home }}/domain/configuration/host.xml

# run the cli file to configure LDAP for authentication
run_ldap_cli:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh --file={{ jboss.cli_file_temp_dir }}/dc_configure_ldap.cli -c --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'
    - require:
      - file: dc_configure_ldap.cli
    - user: {{ jboss.jboss_user }}
    - unless: grep "{{ jboss.ldap.server_hostname }}" {{ jboss.jboss_home }}/domain/configuration/host.xml

# restart jboss service
restart_jboss_servers_after_ldap_config:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c --command='/host=master/:shutdown(restart=true)' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'
    - require:
      - cmd: run_ldap_cli
    - user: {{ jboss.jboss_user }}

# set "jboss_ldap_configured" grain to true to signify LDAP is configured on this jboss node
jboss_ldap_configured:
  grains.present:
    - require:
      - cmd: restart_jboss_servers_after_ldap_config
    - value: True

# remove the .cli file from the host
remove_ldap_cli_file:
  file.absent:
    - name: {{ jboss.cli_file_temp_dir }}/dc_configure_ldap.cli

    
{%- endif %}
{%- endif %}