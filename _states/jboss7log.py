# -*- coding: utf-8 -*-
'''
Manage JBoss 7 Application Server logging configuration via CLI interface

.. versionadded:: 2015.5.0

This state uses jboss-cli.sh script from JBoss installation and parses its output to determine execution result.

In order to run each state, jboss_config dictionary with the following properties must be passed:

.. code-block:: yaml

   jboss:
      cli_path: '/usr/share/jbossas/bin/jboss-cli.sh'
      controller: localhost:9999
      cli_user: 'jbossadm'
      cli_password: 'jbossadm'


'''

import logging

# Import Salt libs
from salt.exceptions import SaltInvocationError

log = logging.getLogger(__name__)


def configure(name, jboss_config, jboss_logging, force=True, profile=None):
    '''
    Configures the logging in JBoss using 'jboss_logging' dict

    jboss_config
        Configuration dictionary with properties specified above.
    jboss_logging
        Dictionary that specifies logging handlers and loggers
        and their respective attributes
    force
        If True, then enforces the Salt configuration 
    profile
        The JBoss profile (domain mode only)
    '''
    log.debug(" ======================== STATE: jboss7log.configure (name: %s) ", name)
    ret = {'name': name,
           'result': True,
           'changes': {},
           'comment': ''}

    handlers = jboss_logging['handlers']

    ## if a handler is in salt, we need to make sure it is JBoss and has the right attributes
##    for handler in handlers:
        ## TODO
##        handler_exists_ret = handler_exists(name='mommy', handler=handler, jboss_config=jboss_config, profile=profile)
		
    ## if handler is in JBoss but not in salt, then we need to delete it
############## CAREFUL WITH THIS - WE DON'T WANT TO DELETE THE BUILT-IN HANDLERS DO WE? #######################

##    ret['comment'] = handlers	

    return ret


def handler_exists(jboss_config, name, handler_type, handler, force=True, profile=None):
    '''
    Ensures that a given JBoss logging handler exists with the correct attributes.

    jboss_config
        Configuration dictionary with properties specified above.
    name
        The name of the JBoss log handler
    handler_type
        The type of the JBoss log handler
    handler
        Dictionary containing handler attributes
    force
        It True, then enforces the Salt configuration
    profile
        The JBoss profile (domain mode only)

    Example:

    .. code-block:: yaml
        app_log_Handler:
          jboss7log.handler_exists:
            - handler:
                append: True
                autoflush: True
                enabled: True
                file:
                    path: application.log
                    relative-to: jboss.server.log.dir
                level: DEBUG
                name: handler-app.log
                suffix: .yyyy-MM-dd
            - handler_type: periodic-rotating-file-handler
            - profile: full-ha
            - force: True
            - jboss_config:
                cli_path: '{{ jboss_settings.jboss_home }}/bin/jboss-cli.sh'
                controller: localhost:9999
                cli_user: '{{ jboss_settings.admin_account.username }}'
                cli_password: '{{ jboss_settings.admin_account.password }}'
    '''
    log.debug(" ======================== STATE: jboss7.handler_exists (name: %s) ", name)
    ret = {'name': name,
           'result': True,
           'changes': {},
           'comment': ''}

    has_changed = False
    handler_result = __salt__['jboss7log.read_handler'](jboss_config = jboss_config,
                                                        name = handler['name'], 
                                                        handler_type = handler_type, 
                                                        profile = profile)

    if handler_result['success']:
        handler_current_properties = handler_result['result']
        # This handler exists in JBoss but we need to make sure the attributes are right
	set_handler_attr_result = set_handler_attributes(jboss_config=jboss_config,
                                                                   name = handler['name'],
                                                                   handler_type = handler_type,
                                                                   handler=handler,
                                                                   force=force,
                                                                   profile=profile)
    else:
        # This handler does not exist in JBoss - so we need to add it
        add_handler_result = __salt__['jboss7log.add_handler'](jboss_config=jboss_config,
                                                     name = handler['name'],
                                                     handler_type = handler_type,
                                                     handler=handler,
                                                     profile=profile)

#    log.debug('set_handler_Attr_result %s', set_handler_attr_result)
#    log.debug('ret.name %s',ret['name'])
#    log.debug('ret.result %s', ret['result'])
#    log.debug('ret.changes %s', ret['changes'])
#    log.debug('ret.comment %s', ret['comment'])

    return ret

def set_handler_attributes(jboss_config, name, handler_type, handler, force=True, profile=None):
    '''
    Set the attributes of a log handler. The log handler must already exist.

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
    handler
        Dict containing log handler attributes
    force
        If True, then the handler attributes that do not exist in Salt are removed from JBoss. 
        Defaults to True
    profile
        The JBoss profile (domain mode only)

    .. code-block:: yaml

        app_log_Handler:
          jboss7log.set_handler_attributes:
            - jboss_config: {{ pillar['jboss'] }}
            - handler:
              autoflush: 'true'
              enabled: 'true'
              level: ALL
              file-relative-to: jboss.server.log.dir
              max-backup-index: 10
              name: handler-app.log
              path: app.log
              profile: full-ha
              rotate-size: 2m
              suffix: .yyyy-MM-dd
              type: periodic-rotating-file-handler

    '''
    log.debug("======================== MODULE FUNCTION: jboss7log.set_handler_attributes, name=%s, handler_type=%s, handler=%s, force=%s", name, handler_type, handler, force )
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': ''}
    # counters for returned comment values
    attr_changed_count = 0
    attr_added_count = 0
    attr_undefined_count = 0

    comments = []

    jbosshandler_return=__salt__['jboss7log.read_handler'](jboss_config=jboss_config, name=handler['name'], handler_type=handler_type, profile=profile)

    # add new attrbutes and modify existing attributes
    for handler_attr_k, handler_attr_v in handler.items():
        found_handler_attr = False
        for jbosshandler_attr_k, jbosshandler_attr_v in jbosshandler_return['result'].items():
            if handler_attr_k == jbosshandler_attr_k:
                # we found an attribute match
                found_handler_attr = True
                if isinstance(jbosshandler_attr_v,dict):
                    if dict(handler_attr_v) == jbosshandler_attr_v:
                        # convert the salt OrderedDict value to "plain" dict for comparison purposes
                        handler_attr_v = dict(handler_attr_v)
                if handler_attr_v != jbosshandler_attr_v:
                    # update attribute value
                    if __opts__['test']:
                        attr_changed_count += 1
                    else:
                        if isinstance(handler_attr_v,dict):
                            log.debug('ZZZ handler_attr_v is %s',handler_attr_v)
                            attribute_value = __salt__['jboss7log.dict_to_sorted_jboss_object_string'](handler_attr_dict=handler_attr_v)
                        else:
                            attribute_value = handler_attr_v
                        update_handler_attr_return = __salt__['jboss7log.write_handler_attribute'](jboss_config=jboss_config, name=handler['name'], handler_type=handler_type, attribute_name = handler_attr_k, attribute_value = attribute_value, profile=profile)
                        if update_handler_attr_return['success']:
                            change = {'new': handler_attr_v,
                                      'old': jbosshandler_attr_v}
                            ret['changes'][jbosshandler_attr_k] = change
                            attr_changed_count += 1
                        else:
                            comments.append('Failed to change attribute {0} from {1} to {2}'.format(handler_attr_k, jbosshandler_attr_v, handler_attr_v))
                            ret['result'] = False
        if found_handler_attr == False:
            # add attribute
            if __opts__['test']:
                attr_added_count += 1
            else:
                add_handler_attr_return = __salt__['jboss7log.write_handler_attribute'](jboss_config=jboss_config, name=handler['name'], handler_type=handler_type, attribute_name = handler_attr_k, attribute_value = handler_attr_v, profile=profile)
                if add_handler_attr_return['success']:
                    attr_added_count += 1
                else:
                    comments.append('Failed to add attribute {0} with value'.format(handler_attr_k, handler_attr_v))
                    ret['result'] = False
   
    # remove log handler attributes in JBoss that are not in Salt (only if force == True)
    if force == True:
        # need to get a fresh list of attributes for this handler from JBoss
        jbosshandler_return=__salt__['jboss7log.read_handler'](jboss_config=jboss_config, name=handler['name'], handler_type=handler_type, profile=profile)
        for jbosshandler_attr_k, jbosshandler_attr_v in jbosshandler_return['result'].items():
            if jbosshandler_attr_v is not None:
                # (JBoss undefined is represented as None in python)
                for handler_attr_k in handler.keys():
                    if handler_attr_k == jbosshandler_attr_k:
                        # we found this attribute so we can break out
                        break
                else:
                    # this attribute is NOT in salt, so we must delete it in JBoss
                    if __opts__['test']:
                        attr_undefined_count += 1
                    else:
                        undefine_handler_attr_return = __salt__['jboss7log.undefine_handler_attribute'](jboss_config=jboss_config, name=handler['name'], handler_type=handler_type, attribute_name = jbosshandler_attr_k, profile=profile)
                        if undefine_handler_attr_return['success']:
                            change = {'new': 'undefined or default',
                                      'old': jbosshandler_attr_v}
                            ret['changes'][jbosshandler_attr_k] = change
                            attr_undefined_count += 1
                        else:
                            comments.append('Failed to set handler attribute {0} to undefined or default value'.format(jbosshandler_attr_k))
                            ret['result'] = False

    # prepare return information
    if __opts__['test']:
        comments.append('TEST MODE Attributes Changed {0} Added: {1} Undefined: {2}'.format(attr_changed_count, attr_added_count, attr_undefined_count))
    else:
        comments.append('Attributes Changed: {0} Added: {1} Undefined: {2}'.format(attr_changed_count, attr_added_count, attr_undefined_count))
    ret['comment'] = '\n'.join(comments)
    return ret
