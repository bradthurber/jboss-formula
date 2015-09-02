{% from "jboss/map.jinja" import jboss_settings with context %}

include:
  - jboss.service

add_user_temp_admin:
  cmd.run:
    - name: {{ jboss_settings.jboss_home }}/bin/add-user.sh -u '{{ jboss_settings.admin_account.username }}' -p '{{ jboss_settings.admin_account.password }}' -g 'admin'
    - user: {{ jboss_settings.jboss_user }}
    - unless: grep "{{ jboss_settings.admin_account.username }}" {{ jboss_settings.jboss_home }}/domain/configuration/mgmt-users.properties
