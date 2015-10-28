{% from "jboss/map.jinja" import jboss with context %}

include:
  - jboss

###########################################
# THIS IS A WORK IN PROGRESS TO CONFIGURE JBOSS FOR JCONSOLE
#
# Right now it is just pseudocode!!!
#######################################  
  
  
STEP 1  
  # TODO: salt this
### THIS IS DONE ON THE DOMAIN CONTROLLER
# Set the remoting-connector in the jmx substem to NOT use the managment endpoint
# /profile=full-ha/subsystem=jmx/remoting-connector=jmx:add(use-management-endpoint=false)
# Ref: https://access.redhat.com/solutions/443033    


#### RESULT LOOKS LIKE THIS---  
[root@t-cdc-jbdom-01 bin]# ./jboss-cli.sh -c
Username: Brad.Thurber
Password:
[domain@localhost:9999 /] /profile=full-ha/subsystem=jmx/remoting-connector=jmx:add(use-management-endpoint=false)
{
    "outcome" => "success",
    "result" => undefined,
    "server-groups" => undefined
}  

STEP 2
On the gui console, add the jconsole user as ApplicationRealm user


STEP 3    
### THIS IS ON EACH JBOSS SERVER I GUESS  
# in order to use home/bin/jconsole.sh a superuser account must be created under the ApplicationRealm
# Ref: https://access.redhat.com/solutions/443033
add_user_jconsole_account:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/add-user.sh -u '{{ jboss.jconsole_account.username }}' -p '{{ jboss.jconsole_account.password }}' -g 'superuser' -a
    - user: {{ jboss.jboss_user }}
    - unless: grep "{{ jboss.jconsole_account.username }}" {{ jboss.jboss_home }}/domain/configuration/application-users.properties

### correct command is ./add-user.sh -u jconsole -p jconsole1 -g 'superuser' -a    
###
### result should be 
### Added user 'jconsole' to file '/etc/jbossas/standalone/application-users.properties'
Added user 'jconsole' to file '/etc/jbossas/domain/application-users.properties'
Added user 'jconsole' with groups superuser to file '/etc/jbossas/standalone/application-roles.properties'
Added user 'jconsole' with groups superuser to file '/etc/jbossas/domain/application-roles.properties'    
    
STEP 4
make sure the servers you are wanting to monitor are in the full-ha profile!!

STEP 5
* Connect to the server via jconsole.sh
service:jmx:remoting-jmx://{$HOSTNAME}:4447