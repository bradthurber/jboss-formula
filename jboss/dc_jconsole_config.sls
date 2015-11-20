{% from "jboss/map.jinja" import jboss with context %}

include:
  - jboss

###########################################
# THIS IS A WORK IN PROGRESS TO CONFIGURE JBOSS FOR JCONSOLE
#
# Right now it is just pseudocode!!!
#
# This needs to be split into a file for domain controller and a file for each machine running JVMs
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

jconsole requires jdk (to get jconsole) tools.jar from jre, jboss-cli-client.jar from jboss/bin/client dir
optionally requires file jboss-cli.xml
WINDOWS
"%JAVA_HOME%/bin/jconsole.exe" "-J-Djava.class.path=%JAVA_HOME%/lib/jconsole.jar;%JAVA_HOME%/lib/tools.jar;c:\jboss-cli-client.jar" 

LINUX
jconsole -J-Djava.class.path=/usr/lib/jvm/java-1.8.0-oracle-1.8.0.25.x86_64/lib/jconsole.jar;/usr/lib/jvm/java-1.8.0-oracle-1.8.0.25.x86_64/lib/tools.jar;/usr/share/jbossas/bin/client/jboss-cli-client.jar

