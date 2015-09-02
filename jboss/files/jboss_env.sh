{%- from "jboss/map.jinja" import jboss_settings with context %}
# This file managed by Salt, do not edit by hand!!

export {{ jboss_settings.jboss_home_environment_var }}="{{ jboss_settings.jboss_home }}"
