{% from "jboss/map.jinja" import jboss with context %}

{% for datasource_name, datasource_properties in jboss.datasources.items() -%}
datasource_exists_{{ datasource_name }}:
  jboss7.datasource_exists:
    - name: {{ datasource_name }}:
    - recreate: False
    - datasource_properties: {{ datasource_properties }}
    - jboss_config:  {{ jboss.jboss_config }}
    - profile: 'full-ha'
{% endfor %}

