{% from "jboss/map.jinja" import jboss with context %}

include:
  - jboss
  - add_user_temp_admin

# open interface management
open_interface_management:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c --command='/host=master/interface=management:write-attribute(name=inet-address,value="${jboss.bind.address.management:0.0.0.0}"' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'
    - require:
      - cmd: add_user_temp_admin
    - unless: grep "jboss.bind.address.management:0.0.0.0" {{ jboss.jboss_home }}/domain/configuration/host.xml
    - user: {{ jboss.jboss_user }}    
    - watch_in:
      - module: jboss-restart

# open interface public
open_interface_public:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c --command='/host=master/interface=public:write-attribute(name=inet-address,value="${jboss.bind.address:0.0.0.0}"' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'
    - require:
      - cmd: add_user_temp_admin
    - unless: grep "jboss.bind.address:0.0.0.0" {{ jboss.jboss_home }}/domain/configuration/host.xml
    - user: {{ jboss.jboss_user }}
    - watch_in:
      - module: jboss-restart
    
# open interface unsecure
open_interface_unsecure:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c --command='/host=master/interface=unsecure:write-attribute(name=inet-address,value="${jboss.bind.address.unsecure:0.0.0.0}"' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'
    - require:
      - cmd: add_user_temp_admin    
    - unless: grep "jboss.bind.address.unsecure:0.0.0.0" {{ jboss.jboss_home }}/domain/configuration/host.xml
    - user: {{ jboss.jboss_user }}
    - watch_in:
      - module: jboss-restart
