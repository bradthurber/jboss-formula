{% from "jboss/map.jinja" import jboss with context %}

{%- set jboss_domain_controller = salt['grains.get']('jboss_domain_controller', False) %}
{%- if jboss_domain_controller == true %}  

include:
  - jboss
  
# collect the IP addresses for all the apache mod_cluster servers in this jboss environment (grain: environment)
{%- set minion_jboss_environment = grains['environment'] %}
{%- set apache_ips=[] %}
{%- for server, addrs in salt['mine.get']('G@roles:mod-cluster-server and G@environment:'~minion_jboss_environment, 'network.ip_addrs', expr_form='compound').items() %}
# so addrs contains a bunch of IPs at this point. I need to make a var and stuff
# them in comma sep format like this
# 10.139.2.38:6666, 10.150.4.3:6666, 10.2.4.1:6666 
{%- do apache_ips.append(addrs[0]+':6666') %}
{%- endfor %}

# turn off mod_cluster advertisement
turn_off_mod_cluster_advertisement:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c '/profile=full-ha/subsystem=modcluster/mod-cluster-config=configuration/:write-attribute(name=advertise,value=false)' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}' 
    - onlyif: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c '/profile=full-ha/subsystem=modcluster/mod-cluster-config=configuration/:read-attribute(name=advertise)' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}' |grep 'result'|grep true
    - user: {{ jboss.jboss_user }}
        
# tell JBoss server the IP addresses of all the apache servers in this jboss domain (grain: environment)     
configure_mod_cluster_apache_host_ips:
  cmd.run:
    - name: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c '/profile=full-ha/subsystem=modcluster/mod-cluster-config=configuration/:write-attribute(name=proxy-list,value="{{ apache_ips |join(', ') }}")' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}' 
    - unless: {{ jboss.jboss_home }}/bin/jboss-cli.sh -c '/profile=full-ha/subsystem=modcluster/mod-cluster-config=configuration/:read-attribute(name=proxy-list)' --user='{{ jboss.admin_account.username }}' --password='{{ jboss.admin_account.password }}' | grep '"{{ apache_ips |join(', ') }}"'
    - user: {{ jboss.jboss_user }}
    
{%- endif %}   