{% from "jboss/map.jinja" import jboss_settings with context %}

# restart jboss service
util_restart_jboss_service:
  module.run:
    - name: service.restart
    - m_name: {{ jboss_settings.service }} 