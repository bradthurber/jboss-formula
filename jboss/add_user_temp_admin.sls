{% from "jboss/map.jinja" import jboss with context %}

include:
  - jboss

# passwords with symbols tend to cause grief with scripting
relax_symbol_restrict_on_add_user_password:
  file.replace:
    - name: {{ jboss.jboss_home }}/bin/add-user.properties
    - pattern: ^password\.restriction\.minSymbol=(1)$
    - repl: password.restriction.minSymbol=0    

add_user_temp_admin:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/add-user.sh -u '{{ jboss.admin_account.username }}' -p '{{ jboss.admin_account.password }}' -g 'admin'
    - user: {{ jboss.jboss_user }}
    - unless: grep "{{ jboss.admin_account.username }}" {{ jboss.jboss_home }}/domain/configuration/mgmt-users.properties
    - require:
      - file: relax_symbol_restrict_on_add_user_password