{% from "jboss/map.jinja" import jboss_settings with context %}

include:
  - jboss.service

# open interface management
open_interface_management:
  cmd.run:
    - name: {{ jboss_settings.jboss_home }}/bin/jboss-cli.sh -c --command='/host=master/interface=management:write-attribute(name=inet-address,value="${jboss.bind.address.management:0.0.0.0}"' --user='{{ jboss_settings.admin_account.username }}' --password='{{ jboss_settings.admin_account.password }}'
    - user: {{ jboss_settings.jboss_user }}
    - unless: grep "jboss.bind.address.management:0.0.0.0" {{ jboss_settings.jboss_home }}/domain/configuration/host.xml

# open interface public
open_interface_public:
  cmd.run:
    - name: {{ jboss_settings.jboss_home }}/bin/jboss-cli.sh -c --command='/host=master/interface=public:write-attribute(name=inet-address,value="${jboss.bind.address:0.0.0.0}"' --user='{{ jboss_settings.admin_account.username }}' --password='{{ jboss_settings.admin_account.password }}'
    - user: {{ jboss_settings.jboss_user }}
    - unless: grep "jboss.bind.address:0.0.0.0" {{ jboss_settings.jboss_home }}/domain/configuration/host.xml

# open interface unsecure
open_interface_unsecure:
  cmd.run:
    - name: {{ jboss_settings.jboss_home }}/bin/jboss-cli.sh -c --command='/host=master/interface=unsecure:write-attribute(name=inet-address,value="${jboss.bind.address.unsecure:0.0.0.0}"' --user='{{ jboss_settings.admin_account.username }}' --password='{{ jboss_settings.admin_account.password }}'
    - user: {{ jboss_settings.jboss_user }}
    - unless: grep "jboss.bind.address.unsecure:0.0.0.0" {{ jboss_settings.jboss_home }}/domain/configuration/host.xml

    
# restart jboss service on interface change
restart_jboss_service_on_interface_change:
  module.wait:
    - name: service.restart
    - m_name: {{ jboss_settings.service }}
    - watch:
      - cmd: open_interface_unsecure
      - cmd: open_interface_public
      - cmd: open_interface_management