{% from "jboss/map.jinja" import jboss with context %}

include:
  - jboss
  
##### setup configuration group and server groups across cluster
##### 

{% for app in jboss.clusterapps %}
 # create a server group "sg-poc"
create_server_group_{{ app }}:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c '/server-group=sg-poc/:add(socket-binding-group=full-ha-sockets,profile=full-ha)' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}' 
    - unless: {{ jboss.jboss_home }}/bin//jboss-cli.sh -c '/server-group=sg-{{ app }}/:read-resource' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'
    - user: {{ jboss.jboss_user }}


{%- from "jbossapache/map.jinja" import jbossapache_settings with context %}
{%- set mod_cluster_settings = jbossapache_settings.mod_cluster %}

{%- set minion_jboss_environment_name = grains['environment'] %}
{%- for server, addrs in salt['mine.get']('G@roles:mod-cluster-node and G@environment:'~minion_jboss_environment_name, 'network.ip_addrs', expr_form='compound').items() %}
    
 # create server config "{{ app }}"
create_server_{{ server  }}_config_{{ app }}:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c '/host={{ server }}/server-config={{ app }}/:add(auto-start=true,group=sg-{{ app }},socket-binding-port-offset=1000)' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}' 
    - unless: {{ jboss.jboss_home }}/bin//jboss-cli.sh -c '/host={{ server }}/server-config={{ app }}/:read-resource' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}'
    - user: {{ jboss.jboss_user }}

 # start the "{{ app }}" server
start_{{ app }}_server:
  cmd.wait:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c '/host=master/server-config={{ app }}/:start' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}' 
    - watch:
      - cmd: create_server_{{ server  }}_config_{{ app }}
    - user: {{ jboss.jboss_user }}    

{%- endfor %}

  




