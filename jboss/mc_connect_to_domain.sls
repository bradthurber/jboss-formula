{% from "jboss/map.jinja" import jboss with context %}

{% set jboss_domain_controller = salt['grains.get']('jboss_domain_controller', False) %}
{% if jboss_domain_controller == false %}  

{% set connector_username = salt['pillar.get']('jboss:domain_connector:username') %}

{# TODO: once salt Boron (post 2015.8.0) is available then salt can do the encoding #}
{% set connector_base64_password = salt['pillar.get']('jboss:domain_connector:password_base64_encoded') %}
{% set mc_hostname = grains.get('host') %}
{%- set minion_jboss_environment = grains['environment'] %}
    
include:
  - jboss
  - python.augeas

ldap_security_realm:
  augeas.change:
    - context: /files/tmp/host.xml
#    - context: {{ jboss.jboss_home }}/domain/configuration/host.xml
    - changes:
      - rm /host/management/security-realms/security-realm[#attribute/name="LdapManagementRealm"]
      - ins security-realm after /host/management/security-realms/security-realm[last()]
      - set /host/management/security-realms/security-realm[last()]/#attribute/name "LdapManagementRealm"
      - set /host/management/security-realms/security-realm[#attribute/name="LdapManagementRealm"]/server-identities
      - set /host/management/security-realms/security-realm[#attribute/name="LdapManagementRealm"]/server-identities/secret
      - set /host/management/security-realms/security-realm[#attribute/name="LdapManagementRealm"]/server-identities/secret/#attribute/value "{{ connector_base64_password }}"
    - lens: Xml.lns
    - require:
      - pkg: python-augeas

#           - ins security-realm after /host/management/security-realms/security-realm[last()]
#    - set /host/management/security-realms/security-realm[last()]/#attribute/name "LdapManagementRealm"

#change_member_controller_jboss_host_name_from_master_to_{{ mc_hostname }}:
# cmd.run:
    # - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c --command='/host=master/:write-attribute(name=name,value={{ mc_hostname }})'
    # - user: {{ jboss.jboss_user }}
    # - onlyif: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c --command='/host=master/:read-resource(attributes-only=true)'
    # - watch_in:
      # - module: jboss-restart
  
# member_controller_{{ mc_hostname }}_add_ldap_security_realm:
  # cmd.run:
    # - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c --command='/host={{ mc_hostname }}/core-service=management/security-realm=LdapManagementRealm/:add'
    # - user: {{ jboss.jboss_user }}
    # - unless: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c --command='/host={{ mc_hostname }}/core-service=management/:read-children-names(child-type=security-realm)' | grep LdapManagementRealm
    
# member_controller_{{ mc_hostname }}_add_connector_password_as_ldap_realm_secret:
  # cmd.run:
    # - user: {{ jboss.jboss_user }}
    # - name: >-
        # {{ jboss.jboss_home }}/bin/jboss-cli.sh -c --command='/host={{ mc_hostname }}/core-service=management/security-realm=LdapManagementRealm/server-identity=secret:add(value="'{{ connector_base64_password }}'")'
    # - unless: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c --command='/host={{ mc_hostname }}/core-service=management/security-realm=LdapManagementRealm/:read-children-names(child-type=server-identity)'|grep secret    
        
# stop_jboss_service_on_member_on_ldap_realm_secret_add:
  # module.wait:
    # - name: service.stop
    # - m_name: {{ jboss.service }}
    # - watch:
      # - cmd: member_controller_{{ mc_hostname }}_add_connector_password_as_ldap_realm_secret

member_controller_{{ mc_hostname }}_config_remote_dc:
  file.blockreplace:
    - marker_start: '<domain-controller>'
    - marker_end: '</domain-controller>'
    - name: {{ jboss.jboss_home }}/domain/configuration/host.xml 
    - show_changes: True
    - watch_in:
      - module: jboss-restart
    - content: >
{%- for server, fqdn in salt['mine.get']('G@jboss_domain_controller:True and G@environment:'~minion_jboss_environment, 'fqdn', expr_form='compound').items() %}      
        <remote host="{{ fqdn }}" port="9999" security-realm="LdapManagementRealm" username="{{ connector_username }}"/>
{%- endfor %}      
  
{% endif %}