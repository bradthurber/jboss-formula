{%- from "jboss/map.jinja" import jboss with context %}

{%- if jboss.install_type == 'rpm' %}

#### Un-Install EAP from RedHat supplied RPM's (requires subscription)

{%- for package, version in jboss.rpmpkgs.items() %}
{{ package }}_{{ version }}_uninstall:
  pkg.purged:
    - name: {{ package }}
    - version: {{ version }}
{%- endfor %}


{%- for dir in jboss.uninstall_dirs %}
remove_jboss_directory_{{ dir }}:
  file.absent:
    - name: {{ dir }}
{%- endfor %}


## TODO: uninstall for non-rpm based installations. 

{%- endif %}

## Remove the grains used by a JBoss install
remove_grain_jboss_ldap_configured:
  grains.absent:
    - name: jboss_ldap_configured
    - destructive: True
remove_grain_jboss_role:
  grains.list_absent:
    - name: roles
    - value: jboss
remove_grain_jboss_domain_controller:
  grains.absent:
    - name: jboss_domain_controller
    - destructive: True
remove_grain_mod-cluster-node:
  grains.list_absent:
    - name: roles
    - value: mod-cluster-node
