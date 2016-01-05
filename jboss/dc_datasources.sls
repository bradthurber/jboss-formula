{% from "jboss/map.jinja" import jboss with context %}

{% for datasource_name, datasource_properties in jboss.datasources.items() -%}
datasource_exists_{{ datasource_name }}:
  {{ ds_name }}:
    jboss7.datasource_exists:
     - recreate: False
     - datasource_properties: {{ datasource_properties }}
     - jboss_config:  {{ jboss.jboss_config }}
     - profile: 'full-ha'
{% endfor %}

