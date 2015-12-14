# -*- coding: utf-8 -*-
'''
Module for managing JBoss AS 7 logging

In order to run each function, jboss_config dictionary with the following properties must be passed:
 * cli_path: the path to jboss-cli script, for example: '/opt/jboss/jboss-7.0/bin/jboss-cli.sh'
 * controller: the ip addres and port of controller, for example: 10.11.12.13:9999
 * cli_user: username to connect to jboss administration console if necessary
 * cli_password: password to connect to jboss administration console if necessary
Example:
.. code-block:: yaml
   jboss_config:
      cli_path: '/opt/jboss/jboss-7.0/bin/jboss-cli.sh'
      controller: 10.11.12.13:9999
      cli_user: 'jbossadm'
      cli_password: 'jbossadm'
'''

# Import python libs
import logging

log = logging.getLogger(__name__)


def add_handler(jboss_config, name, handler_type, handler, profile=None):
    '''
    Add a JBoss log handler resource.

    jboss_config
        The jboss_config dict
    name
        The name of the log handler
    handler_type
        The type of the log handler
    handler
        Dict of the handler attributes
    profile
        The profile name (JBoss domain mode only)

    CLI Example:
    .. code-block:: bash
        salt '*' jboss7log.add_handler 'TODO:'
    '''
    log.debug("======================== MODULE FUNCTION: jboss7log.add_handler, name=%s, handler_type=%s, profile=%s", name, handler_type, handler, profile)
    return __add_handler(jboss_config=jboss_config, name=name, handler_type=handler_type, handler=handler, profile=profile)    

def read_handler(jboss_config, name, handler_type, profile=None):
    '''
    Read a log handler resource.

    jboss_config
        The jboss_config dict
    name
        The name of the handler
    handler_type
       The type of the log handler. One of:
           async-handler
           console-handler
           custom-handler
           file-handler
           periodic-rotating-file-handler
           periodic-size-rotating-file-handler
           size-rotating-file-handler
    profile
        The profile name (JBoss domain mode only)

    CLI Example:

    .. code-block:: bash
        salt '*' jboss7log.read_handler '{"cli_password": "badpass", "cli_path": "/usr/share/jbossas/bin/jboss-cli.sh", "cli_user": "adminuser", "controller": "localhost:9999"}' name=FILE handler_type=periodic-rotating-file-handler 'profile'='full-ha'
    '''
    log.debug("======================== MODULE FUNCTION: jboss7log.read_handler, name=%s, type=%s, profile=%s", name, type, profile)
    return __read_handler(jboss_config=jboss_config, name=name, handler_type=handler_type, profile=profile)


def write_handler_attribute(jboss_config, name, handler_type, attribute_name, attribute_value, profile=None):
    '''
    Write an attribute value for a JBoss log handler

    jboss_config
        The jboss_config dict
    name
        The name of the log handler
    handler_type
        The type of the log handler. One of: 
            async-handler 
            console-handler
            custom-handler
            file-handler
            periodic-rotating-file-handler
            periodic-size-rotating-file-handler
            size-rotating-file-handler
    attribute_name
        The name of the handler attribute
    attribute_value
        The value of the handler attribute
    profile
        The profile name (JBoss domain mode only)

    CLI Example:
    '' code-block:: bash
        salt '*' jboss7log.write_handler_attribute '{"cli_password": "badpass", "cli_path": "/usr/share/jbossas/bin/jboss-cli.sh", "cli_user": "jbossadmin", "controller": "localhost:9999"}' name='handler-app.log' handler_type='periodic-rotating-file-handler' attribute_name='level' attribute_value='INFO' profile='full-ha' 
   
    '''
    log.debug("======================== MODULE FUNCTION: jboss7log.write_handler_attribute, name=%s, handler_type=%s, attribute_name=%s, attribute_value=%s, profile=%s", name, handler_type, attribute_name, attribute_value, profile)
    return __write_handler_attribute(jboss_config, name, handler_type, attribute_name, attribute_value, profile)

def undefine_handler_attribute(jboss_config, name, handler_type, attribute_name, profile=None):
    '''
    Underfine an attribute value for a JBoss log handler

    jboss_config
        The jboss_config dict
    name
        The name of the log handler
    handler_type
        The type of the log handler. One of:
            async-handler
            console-handler
            custom-handler
            file-handler
            periodic-rotating-file-handler
            periodic-size-rotating-file-handler
            size-rotating-file-handler
    attribute_name
        The name of the handler attribute
    attribute_value
        The value of the handler attribute
    profile
        The profile name (JBoss domain mode only)

    CLI Example:
    '' code-block:: bash
    TODO:    

    '''
    log.debug("======================== MODULE FUNCTION: jboss7log.undefine_handler_attribute, name=%s, handler_type=%s, attribute_name=%s, profile=%s", name, handler_type, attribute_name, profile)
    return __undefine_handler_attribute(jboss_config, name, handler_type, attribute_name, profile)


def __read_handler(jboss_config, name, handler_type, profile=None):
    operation = '/subsystem=logging/"{handler_type}"="{name}"/:read-resource(recursive-depth=0,include-runtime=true,include-defaults=false)'.format(name=name, handler_type=handler_type)
    if profile is not None:
        operation = '/profile="{profile}"'.format(profile=profile) + operation    
    
    operation_result = __salt__['jboss7_cli.run_operation'](jboss_config, operation)

    return operation_result


def __add_handler(jboss_config, name, handler_type, handler, profile=None):
    attr_string=__handler_attr_string(handler)
    operation = '/subsystem=logging/{handler_type}="{name}"/:add({attributes})'.format(name=name, handler_type=handler_type, attributes=attr_string)
    if profile is not None:
        operation = '/profile="{profile}"'.format(profile=profile) + operation

    operation_result=__salt__['jboss7_cli.run_operation'](jboss_config, operation)

    return operation_result

def __undefine_handler_attribute(jboss_config, name, handler_type, attribute_name, profile=None):
    operation = '/subsystem=logging/{handler_type}="{name}"/:undefine-attribute(name={attribute_name})'.format(name=name, handler_type=handler_type, attribute_name=attribute_name)
    if profile is not None:
        operation = '/profile="{profile}"'.format(profile=profile) + operation

    operation_result=__salt__['jboss7_cli.run_operation'](jboss_config, operation)

    return operation_result


def __write_handler_attribute(jboss_config, name, handler_type, attribute_name, attribute_value, profile=None):
    # special case - the "path" attribute value must NOT be quoted
    if attribute_name == 'path':
        attr_val=attribute_value
    else:  
        attr_val = "\"{0}\"".format(attribute_value)
    log.debug('ZZZZZ %s',attr_val)
    operation = '/subsystem=logging/{handler_type}="{name}"/:write-attribute(name={attribute_name},value={attr_val})'.format(name=name, handler_type=handler_type, attribute_name=attribute_name, attr_val=attr_val)
    if profile is not None:
        operation = '/profile="{profile}"'.format(profile=profile) + operation

    operation_result=__salt__['jboss7_cli.run_operation'](jboss_config, operation)

    return operation_result

def __handler_attr_string(handler):
    '''
    Concatenates all the attributes given for a JBoss logging handler into a single string
    '''
    attributes = []
    for attr_k, attr_v in handler.items():
        if isinstance(attr_v,dict):
            # need to convert 'file' object dict to string before sending to JBoss
            attr_v = dict_to_sorted_jboss_object_string(attr_v)
            # JBoss freaks if object handler "file" object values are in quotes
            attribute = '{0}={1}'.format(attr_k, attr_v)
        else:
            # JBoss freaks if handler "format" attribute values are NOT in quotes
            attribute = '{0}="{1}"'.format(attr_k, attr_v)
        attributes.append(attribute)
    return ','.join(str(x) for x in attributes)


def dict_to_sorted_jboss_object_string(handler_attr_dict):
    '''
    Helper that converts dict key/values to a proprietary JBoss object string format

    An example of where this is needed is the JBoss Log handler - where the 'file' attribute is
    an object, but needs to be converted to a JSON-like string format to be set. Example:

    .. code-block::
    {"path" => "appl.log","relative-to" ==> "jboss.server.log.dir"}
    '''
    attribute_separator=','
    object_start = '{'
    object_end = '}'

    jboss_attributes=[]
    for key in sorted(handler_attr_dict.keys()):
        jboss_attribute = '{0} => {1}'.format(key,handler_attr_dict[key])
        jboss_attributes.append(jboss_attribute)

    return object_start + attribute_separator.join(str(x) for x in jboss_attributes) + object_end

