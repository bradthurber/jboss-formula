{% from "jboss/map.jinja" import jboss with context %}

#app_log_Handler:
#  jboss7log.handler_exists:
#    - handler:
#        append: False
#        autoflush: True
#        enabled: True
#        file:
#            path: app.log
#            relative-to: jboss.server.log.dir
#        level: INFO
#        name: handler-app.log
#        suffix: .yyyy-MM-dd
#        formatter: %d{MMHH:mm:ss,SSS} %-5p [%c] (%t) %s%E%n
#    - handler_type: periodic-rotating-file-handler
#    - profile: full-ha
#    - force: True
#    - jboss_config:
#        cli_path: '{{ jboss.jboss_home }}/bin/jboss-cli.sh'
#        controller: localhost:9999
#        cli_user: '{{ jboss.admin_account.username }}'
#        cli_password: '{{ jboss.admin_account.password }}'

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
    - jboss_config:
        cli_path: '{{ jboss.jboss_home }}/bin/jboss-cli.sh'
        controller: localhost:9999
        cli_user: '{{ jboss.admin_account.username }}'
        cli_password: '{{ jboss.admin_account.password }}'

#configure_the_jboss_logs:        
#  jboss7log.configure:   
#    - name: my_name_value    
#    - jboss_config: 
#         jboss:
#           cli_path: '/usr/share/jbossas/bin/jboss-cli.sh'
#           controller: localhost:9999
#           cli_user: '{{ jboss.admin_account.username }}'
#           cli_password: '{{ jboss.admin_account.password }}'
#    - jboss_logging: {{ jboss.logging }}
