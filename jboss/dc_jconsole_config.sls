{% from "jboss/map.jinja" import jboss with context %}

include:
  - jboss.service

# in order to use home/bin/jconsole.sh a superuser account must be created under the ApplicationRealm
# Ref: https://access.redhat.com/solutions/443033
add_user_jconsole_account:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/add-user.sh -u '{{ jboss.jconsole_account.username }}' -p '{{ jboss.jconsole_account.password }}' -g 'superuser' -r 'ApplicationRealm'
    - user: {{ jboss.jboss_user }}
    - unless: grep "{{ jboss.jconsole_account.username }}" {{ jboss.jboss_home }}/domain/configuration/application-users.properties

# Set the remoting-connector in the jmx substem to NOT use the managment endpoint
# /profile=full-ha/subsystem=jmx/remoting-connector=jmx:add(use-management-endpoint=false)
# Ref: https://access.redhat.com/solutions/443033    
# TODO: salt this



* Connect to the server via service:jmx:remoting-jmx://{$HOSTNAME}:4447