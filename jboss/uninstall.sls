{%- from "jboss/map.jinja" import jboss_settings with context %}

#include:
#  - jboss.service

{%- if jboss_settings.install_type == 'rpm' %}

#### Un-Install EAP from RedHat supplied RPM's (requires subscription)

{%- for package, version in jboss_settings.rpmpkgs.items() %}
{{ package }}_{{ version }}_uninstall:
  pkg.purged:
    - name: {{ package }}
    - version: {{ version }}
{%- endfor %}


{%- for dir in jboss_settings.uninstall_dirs %}
remove_jboss_directory_{{ dir }}:
  file.absent:
    - name: {{ dir }}
{%- endfor %}

    
## TODO: uninstall for non-rpm based installations

{%- endif %}

## Remove the grains used by a JBoss install
remove_grain_jboss_ldap_configured:
  grains.absent:
    - name: jboss_ldap_configured
remove_grain_jboss_role:
  grains.absent:
    - name: roles.jboss
remove_grain_jboss_domain_controller:
  grains.absent:
    - name: roles.jboss-domain-controller
remove_grain_jboss_member_controller:
  grains.absent:
    - name: roles.jboss-member-controller
remove_grain_mod-cluster-node:
  grains.absent:
    - name: roles.mod-cluster-node

  