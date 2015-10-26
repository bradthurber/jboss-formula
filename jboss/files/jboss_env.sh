{%- from "jboss/map.jinja" import jboss with context %}
# This file managed by Salt, do not edit by hand!!

export {{ jboss.jboss_home_environment_var }}="{{ jboss.jboss_home }}"
