{% from "jboss/map.jinja" import jboss with context %}

{% for ds_name, ds_params in jboss.datasources.items() -%}
test_echo_ds_{{ ds_name }}:
  cmd.run:
    - name: 'echo {{ ds_params|json }}'
{% endfor %}

