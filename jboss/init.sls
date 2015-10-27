{%- from "jboss/map.jinja" import jboss with context %}

{%- if jboss.install_type == 'rpm' %}

{%- for package, version in jboss.rpmpkgs.iteritems() %}
{{ package }}_{{ version }}_install:
  pkg.installed:
    - name: {{ package }}
    - version: {{ version }}
{%- endfor %}

{%- elif jboss.install_type == 'zip' %}

# make sure jboss user is present
make_sure_jboss_user_is_present:
  user.present:
    - createhome: False
    - fullname: 'JBoss EAP service user'
    - gid: 185
    - name: {{ jboss.jboss_user }}
    - uid: 185
    
# unzip jboss eap files to minion
unzip {{ jboss.zip_file }}:
  archive.extracted:
    - archive_format: zip
    - archive_user: jboss
    - if_missing: {{ jboss.jboss_home }}/{{ jboss.version_file }}
    - keep: True
    - name: {{ jboss.unzip_path }}
# get the files from s3 until we figure out why salt:// links are not working
#    - source: salt://jboss/files/{{ jboss.zip_file }}
    - source: https://s3.amazonaws.com/karpractice/{{ jboss.zip_file }}
    - source_hash: md5={{ jboss.zip_file_md5 }}

# *TEMPORARY*: Until next salt release (post 2015.5), archive.extracted doesn't put group on extracted dirs/files
# http://docs.saltstack.com/en/develop/ref/states/all/salt.states.archive.html#module-salt.states.archive
set_eap_directory_to_jboss_user_and_group:
  file.directory:
    - name: {{ jboss.jboss_home }}
    - user: {{ jboss.jboss_user }}
    - group: {{ jboss.jboss_user }}
    - recurse:
      - user
      - group
    
# change permission on /bin scripts chmod 755 /jbosshome/bin
# *TEMPORARY* See bug https://github.com/saltstack/salt/issues/23822
make_bin_dir_executable:
  file.directory:
    - name: {{ jboss.jboss_home }}/bin
    - file_mode: 755
    - recurse:
      - mode

create_jbossas_domain_log_directory:
  file.directory:
    - group: {{ jboss.jboss_user }}
    - makedirs: True
    - name: {{ jboss.log_dir_domain }}
    - dir_mode: 755
    - user: {{ jboss.jboss_user }}
    
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

{%- endif %}

{{ jboss.service }}:
  service.running:
    - name: {{ jboss.service }}
    - enable: True

# The following states are inert by default and can be used by other states to
# trigger a restart or reload as needed.
jboss-reload:
  module.wait:
    - name: service.reload
    - m_name: {{ jboss.service }}

jboss-restart:
  module.wait:
    - name: service.restart
    - m_name: {{ jboss.service }}
