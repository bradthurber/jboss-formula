{% from "jboss/map.jinja" import jboss with context %}

{% set minion_ip4 = salt['grains.get']('fqdn_ip4', '0.0.0.0') %}

include:
  - jboss

open_interface_management:
  file.replace:
    - name: {{ jboss.jboss_hostxml }}
    - pattern: (<inet-address value="\$\{jboss\.bind\.address\.management:)(.*)(\}"/>)
    - repl: \g<1>{{ minion_ip4[0] }}\g<3>
    - watch_in:
      - module: jboss-restart

open_interface_public:
  file.replace:
    - name: {{ jboss.jboss_hostxml }}
    - pattern: (<inet-address value="\$\{jboss\.bind\.address:)(.*)(\}"/>)
    - repl: \g<1>{{ minion_ip4[0] }}\g<3>
    - watch_in:
      - module: jboss-restart

open_interface_unsecure:
  file.replace:
    - name: {{ jboss.jboss_hostxml }}
    - pattern: (<inet-address value="\$\{jboss\.bind\.address\.unsecure:)(.*)(\}"/>)
    - repl: \g<1>{{ minion_ip4[0] }}\g<3>
    - watch_in:
      - module: jboss-restart
