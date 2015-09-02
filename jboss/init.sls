{%- from "jboss/map.jinja" import jboss_settings with context %}

#include:
#  - jboss.service

{%- if jboss_settings.install_type == 'rpm' %}

#### Install EAP from RedHat supplied RPM's (requires subscription)

{%- for package, version in jboss_settings.rpmpkgs.iteritems() %}
{{ package }}_{{ version }}_install:
  pkg.installed:
    - name: {{ package }}
    - version: {{ version }}
{%- endfor %}

{%- elif jboss_settings.install_type == 'zip' %}

#### Install EAP using a ZIP file

# make sure jboss user is present
make_sure_jboss_user_is_present:
  user.present:
    - createhome: True
    - fullname: 'JBoss EAP service user'
    - name: {{ jboss_settings.jboss_user }}
    
# unzip jboss eap files to minion
unzip {{ jboss_settings.zip_file }}:
  archive.extracted:
    - archive_format: zip
    - archive_user: jboss
    - if_missing: {{ jboss_settings.jboss_home }}/{{ jboss_settings.version_file }}
    - keep: True
    - name: {{ jboss_settings.unzip_path }}
# get the files from s3 until we figure out why salt:// links are not working
#    - source: salt://jboss/files/{{ jboss_settings.zip_file }}
    - source: https://s3.amazonaws.com/karpractice/{{ jboss_settings.zip_file }}
    - source_hash: md5={{ jboss_settings.zip_file_md5 }}

# *TEMPORARY*: Until next salt release (post 2015.5), archive.extracted doesn't put group on extracted dirs/files
# http://docs.saltstack.com/en/develop/ref/states/all/salt.states.archive.html#module-salt.states.archive
set_eap_directory_to_jboss_user_and_group:
  file.directory:
    - name: {{ jboss_settings.jboss_home }}
    - user: {{ jboss_settings.jboss_user }}
    - group: {{ jboss_settings.jboss_user }}
    - recurse:
      - user
      - group
    
# change permission on /bin scripts chmod 755 /jbosshome/bin
# *TEMPORARY* See bug https://github.com/saltstack/salt/issues/23822
make_bin_dir_executable:
  file.directory:
    - name: {{ jboss_settings.jboss_home }}/bin
    - file_mode: 755
    - recurse:
      - mode

create_jbossas_domain_log_directory:
  file.directory:
    - group: {{ jboss_settings.jboss_user }}
    - makedirs: True
    - name: {{ jboss_settings.log_dir_domain }}
    - dir_mode: 755
    - user: {{ jboss_settings.jboss_user }}

{%- endif %}
