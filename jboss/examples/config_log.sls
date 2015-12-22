{% from "jboss/map.jinja" import jboss with context %}

## Test of just configuring a log handler
new_app_log_Handler:
  jboss7log.handler_exists:
    - handler:
        append: False
        autoflush: True
        enabled: True
        file:
            path: new_app3.log
            relative-to: jboss.server.log.dir
        level: INFO
        name: handler-new-app3.log
        formatter: '%d{HH:mm:ss,SSS} %-5p [%c] (%t) %s%E%n'
        suffix: .yyyy-MM-dd
    - handler_type: periodic-rotating-file-handler
    - profile: full-ha
    - force: True
    - jboss_config:  {{ jboss.jboss_config }}

## Configure the whole logging system by passing in the jboss.logging pillar
##
#configure_the_jboss_logs:        
#  jboss7log.configure:   
#    - name: my_name_value    
#    - jboss_config:  {{ jboss.jboss_config }}
#    - jboss_logging: {{ jboss.logging }}
