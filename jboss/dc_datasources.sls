{% from "jboss/map.jinja" import jboss with context %}

{% for jboss_datasource in jboss.datasources.iteritems() -%}
test_echo_ds:
  cmd.run:
    - name: 'echo {{ jboss_datasource|json }}'
{% endfor %}

