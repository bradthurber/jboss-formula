================
jboss-formula
================

A salt formula that installs and configures JBoss EAP.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.


dc_* states are only meant to be run on a domain controller (not a member)

mc_* states are only meant to be run on a domain member (not a controller)

All other states (unless otherwise mentioned) are meant to be run on any/all jboss servers
	
Available states
================

.. contents::
    :local:

``jboss``
------------

Installs JBoss EAP, and starts the associated service.
Prerequisites: Java 8 must be installed

``jboss.add_user_temp_admin``
------------

Add's a temporary file-based admin user - which is used to run CLI commands prior to configuring LDAP

dc_add_oracle_driver_to_profile
``jboss.dc_add_oracle_driver_to_profile``
------------

Adds the Oracle driver to the full-ha profile

``jboss.dc_configure_ldap``
------------

Switches to RBAC (Role Based Access Control) mode. 
Configures JBoss EAP to run against an LDAP server rather than the local file-based account database

``jboss.dc_configure_roles``
------------

Configures the roles on the jboss domain controller

``jboss.dc_mod_cluster_configuration``
------------

Configures mod_cluster on the domain controller. 

``jboss.dc_remove_invalid_roles``
------------

Looks at all the role/group definitions in JBoss and removes the ones that are not in the salt pillar

``jboss.env``
------------

Set environment variables for JBoss EAP (ex: JBOSS_HOME).

``jboss.open_interfaces``
------------

Opens the management, public and unsecure interfaces to all IP addresses (0,0,0,0)

``jboss.java8_permgen``
------------

Java 8 no longer has a concept of "Permgen" space to store metadata about Java objects. Instead it stores these objects in native memory (aka Metaspace). The default startup of JBoss Domain includes a Permgen "MaxPerSize" configuration parameter. This parameter is ignored in Java 8, but causes a HotSpot warning message.

​ Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=256m; support was removed in 8.0​

``jboss.mc_connect_to_domain``
------------

Connects a JBoss Member Controller to the Domain Controller

``jboss.module_jdbc_oracle``
------------

Copies the jdbc .jar from the Oracle client directory to a new jboss modules directory.
Configures the .jar as a JBoss module

Prerequisite: Oracle Basic client must be installed already

``jboss.open_interfaces``
------------

By default the JBoss interfaces are only available to localhost. this makes them available to any host

``jboss.uninstall``
------------

DANGER - Does what the name implies - fully uninstalls JBoss and removes the JBoss directories. Used primarily for poor-man's testing of the salt JBoss install/config without installing a new OS.
