#!py                                                                                                                                                                                                                

import json

def run():

  '''
  Compare the JBoss role to group mappings as configured in salt
  to the actual configuration in JBoss and remove the ones that do not exist in salt -
  ensuring that Salt is the "sole source of truth" for JBoss role-to-group mappings
  '''

  config={}

  # Derive the base jboss-cli command line
  os = __grains__['os']
  jboss_base='/usr/share/jbossas'
  if os == 'CentOS':
    jboss_base='/opt/jboss/eap/jboss-eap-6.4'
  jboss_admin_user = __pillar__['jboss']['admin_account']['username']
  jboss_admin_password = __pillar__['jboss']['admin_account']['password']
  jboss_cli_base = "{0}/bin/jboss-cli.sh --user='{1}' --password='{2}' -c ".format(jboss_base, jboss_admin_user, jboss_admin_password)

  # get the current raw group map info out of JBoss
  jboss_cli_command_read_role_mappings="'/core-service=management/access=authorization/:read-children-resources(child-type=role-mapping,recursive-depth=0, include-runtime=true)'"
  raw_cli_output=__salt__['cmd.run'](jboss_cli_base + jboss_cli_command_read_role_mappings)

  # convert JBoss non-standard CLI output to JSON by doing some string replacement
  cli_to_json_step1=raw_cli_output.replace('=>',':')
  cli_to_json_step2=cli_to_json_step1.replace('undefined','null')
  cli_to_json_step3=cli_to_json_step2.rstrip()

  # convert cli jsonified result to python dict
  cli_dict=json.loads(cli_to_json_step3)
  cli_result = cli_dict['result']

  # get the current group to roles mapping from the pillar
  role_to_group_pillar = __pillar__['jboss']['jboss_role_to_ldap_group_mapping']

  # iterate through jboss role/group mappings and remove the ones that aren't in salt
  for role, roledict in cli_result.iteritems():
    inc=roledict['include']
    # only dict types have data - so we ignore anything else
    if type(inc)==dict:
      for ldap_group, throwaway in inc.iteritems():
        # all groups start with "group-" in the jboss config
        if ldap_group.startswith('group-'):
          # remove 'group-' from start of ldap_group string before comparing
          stripped_group=ldap_group[6:]
          match=False         
          # for this jboss role to group map see if it is in salt
          for salted_role, salted_group in role_to_group_pillar.iteritems():
            if (salted_role==role and salted_group==stripped_group):
              # this is a valid (it is in salt) role:group mapping no need to do anything
              match=True
              break

          if match==False:
             # did not find a role/group match in the salt config so we need to remove it from jboss
             remove_role_mapping(role, stripped_group, config, jboss_cli_base)
             
  return config

def remove_role_mapping(role_name,
                        group_name,
                        config,
                        jboss_cli_base):
    '''
    Remove a group from a jboss role
    '''

    cli_command="'/core-service=management/access=authorization/role-mapping={role}/include=group-{group}/:remove'".format(role=role_name, group=group_name)

    config['remove_role_mapping__' + role_name + '-' + group_name] = {
      'cmd.run': [
              {'name': jboss_cli_base + cli_command},
      ]
    }
