{% from "jboss/map.jinja" import jboss_settings with context %}

{%- set jboss_domain_controller = salt['grains.get']('jboss_domain_controller', 'False') %}
{%- if jboss_domain_controller == True %}  

{# iterate through the salt pillar JBOSS Role to LDAP Group mappings to make sure all of then exist in JBoss #}
{# note this does not remove mappings that already may exist #}
{%- for jboss_role, ldap_group in jboss_settings.jboss_role_to_ldap_group_mapping.iteritems() %}

{# even standard roles must be created as "resources" first before groups are assigned to them #}
create_jboss_role_resource__{{ jboss_role }}:
  cmd.run:
    - name: {{ jboss_settings.jboss_home }}/bin/jboss-cli.sh -c --command='/core-service=management/access=authorization/role-mapping={{ jboss_role }}/:add' --user='{{ jboss_settings.admin_account.username }}' --password='{{ jboss_settings.admin_account.password }}'
    - user: {{ jboss_settings.jboss_user }}
    - unless: {{ jboss_settings.jboss_home }}/bin/jboss-cli.sh -c --command='/core-service=management/access=authorization/role-mapping={{ jboss_role }}/:read-resource(recursive-depth=0)' --user='{{ jboss_settings.admin_account.username }}' --password='{{ jboss_settings.admin_account.password }}'
  
ensure_jboss_role_to_ldap_group_mapping_exists__{{ jboss_role }}_{{ ldap_group }}:
  cmd.run:
    - name: {{ jboss_settings.jboss_home }}/bin/jboss-cli.sh -c --command='/core-service=management/access=authorization/role-mapping={{ jboss_role }}/include=group-{{ ldap_group }}:add(name={{ ldap_group }}, type=GROUP)' --user='{{ jboss_settings.admin_account.username }}' --password='{{ jboss_settings.admin_account.password }}'
    - user: {{ jboss_settings.jboss_user }}
    - unless: {{ jboss_settings.jboss_home }}/bin/jboss-cli.sh -c --command='/core-service=management/access=authorization/role-mapping={{ jboss_role }}/include=group-{{ ldap_group }}/:read-resource(recursive-depth=0)' --user='{{ jboss_settings.admin_account.username }}' --password='{{ jboss_settings.admin_account.password }}'

{% endfor %}

{%- endif %}