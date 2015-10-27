{% from "jboss/map.jinja" import jboss with context %}

include:
  - jboss
  
##### setup configuration group and server group for the app

 # create a server group "sg-poc"
create_server_group_sg-poc:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c '/server-group=sg-poc/:add(socket-binding-group=full-ha-sockets,profile=full-ha)' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}' 
    - unless: {{ jboss.jboss_home }}/bin//jboss-cli.sh -c '/server-group=sg-poc/:read-resource' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'
    - user: {{ jboss.jboss_user }}

 # create server config "sc-poc"
create_server_config_sc-poc:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c '/host=master/server-config=sc-poc/:add(auto-start=true,group=sg-poc,socket-binding-port-offset=1000)' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}' 
    - unless: {{ jboss.jboss_home }}/bin//jboss-cli.sh -c '/host=master/server-config=sc-poc/:read-resource' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'
    - user: {{ jboss.jboss_user }}

 # start the "sc-poc" server
start_sc-poc_server:
  cmd.wait:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c '/host=master/server-config=sc-poc/:start' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}' 
    - watch:
      - cmd: create_server_config_sc-poc
    - user: {{ jboss.jboss_user }}    
  
#### Deploy the app  
# copy sample war to host
copy_sample_war_to_host:
  file.managed:
    - group: {{ jboss.jboss_user }}
    - mode: 644
    - name: /tmp/sample.war
    - source: salt://jboss/files/sample.war
    - template: jinja
    - unless: ls /tmp/sample.war|grep sample.war
    - user: {{ jboss.jboss_user }}
    
 # run the cli file to deploy the sample war
deploy_the_sample_war:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c 'deploy /tmp/sample.war --all-server-groups' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}' 
    - unless: {{ jboss.jboss_home }}/bin//jboss-cli.sh -c 'deployment-info --name=sample.war' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'|grep RUNTIME
    - user: {{ jboss.jboss_user }}
  
  




