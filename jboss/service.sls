{% from "jboss/map.jinja" import jboss_settings with context %}

{% if jboss_settings.install_type == 'zip' %}
# copy the startup script to the /etc/init.d/ directory
# copy jboss_home/bin/init.d/jboss-as-domain.sh /etc/init.d/jboss-as-domain
copy_jboss_service_startup_script_to_init.d:
  file.managed:
    - group: root
    - makedirs: False
    - mode: 755
    - name: /etc/init.d/jbossas-domain
    - source: salt://jboss/files/service/jbossas-domain
    - user: root

# copy the configuration file to the /etc/jbossas directory
copy_jboss_service_config_file_to_init.d:
  file.managed:
    - dir_mode: 750
    - group: root
    - makedirs: True
    - mode: 644
    - name: /etc/jbossas/jbossas.conf
    - source: salt://jboss/files/service/jbossas.conf
    - template: jinja
    - user: root

{% endif %}
    
{{ jboss_settings.service }}:
  service.running:
    - name: {{ jboss_settings.service }}
    - enable: True
