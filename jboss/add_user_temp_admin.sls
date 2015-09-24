{% from "jboss/map.jinja" import jboss_settings with context %}

include:
  - jboss.service

# passwords with symbols tend to cause grief with scripting
relax_symbol_restrict_on_add_user_password:
  file.replace:
    - name: {{ jboss_settings.jboss_home }}/bin/add-user.properties
    - repl: password.restriction.minSymbol=0
    - pattern: ^password\.restriction\.minSymbol=(1)$
  
password.restriction.minSymbol=1
add_user_temp_admin:
  cmd.run:
    - name: {{ jboss_settings.jboss_home }}/bin/add-user.sh -u '{{ jboss_settings.admin_account.username }}' -p '{{ jboss_settings.admin_account.password }}' -g 'admin'
    - user: {{ jboss_settings.jboss_user }}
    - unless: grep "{{ jboss_settings.admin_account.username }}" {{ jboss_settings.jboss_home }}/domain/configuration/mgmt-users.properties
