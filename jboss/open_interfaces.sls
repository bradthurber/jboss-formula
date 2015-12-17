{% from "jboss/map.jinja" import jboss with context %}

{% set minion_ip4 = salt['grains.get']('fqdn_ip4', '0.0.0.0') %}

include:
  - jboss
  - jboss.add_user_temp_admin

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

#open_interface_public_using_cli:
#  cmd.run:
#    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c --command='/host=master/interface=public:write-attribute(name=inet-address,value="${jboss.bind.address:{{ minion_ip4 }}}"' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'
#    - require:
#      - cmd: add_user_temp_admin
#    - unless: grep "jboss.bind.address:{{ minion_ip4 }}" {{ jboss.jboss_home }}/domain/configuration/host.xml
#    - user: {{ jboss.jboss_user }}
#    - watch_in:
#      - module: jboss-restart

open_interface_public_direct_file_edit:
  file.replace:
    - name: {{ jboss.jboss_hostxml }}
    - pattern: (<inet-address value="\$\{jboss\.bind\.address:)(.*)(\}"/>)
    - repl: \1{{ minion_ip4 }}\3
    - watch_in:
      - module: jboss-restart
    
# open interface unsecure
open_interface_unsecure:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c --command='/host=master/interface=unsecure:write-attribute(name=inet-address,value="${jboss.bind.address.unsecure:{{ minion_ip4 }}}"' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'
    - require:
      - cmd: add_user_temp_admin    
    - unless: grep "jboss.bind.address.unsecure:{{ minion_ip4 }}" {{ jboss.jboss_home }}/domain/configuration/host.xml
    - user: {{ jboss.jboss_user }}
    - watch_in:
      - module: jboss-restart
