########
# To enable cross-node clustering, the JVM jgroups.bind_addr must be set
# -or- we must bind the server to a specific IP address rather than 0.0.0.0
#
# REF: https://access.redhat.com/solutions/486433
#

### need to set the jgroup to the host's IP address for each server config
##
#  This is to enable Session Replication https://access.redhat.com/solutions/486433
#
#
#  For DOMAIN mode
#
#         <server name="app-02-jvm-101" group="main-server-group" auto-start="false">
#            <socket-bindings socket-binding-group="full-ha-sockets" port-offset="0"/>
#                <system-properties>
#                    <property name="jgroups.bind_addr" value="ip.x.y.z" boot-time="true"/>
#                </system-properties>
#        </server>
#
#
#  FOR STANDALONE mode
#  For standalone, add the following jvm option to command line:
# 
#   Raw
#  ./bin/standalone.sh ...(snip)... -Djgroups.bind_addr=192.168.0.100
#
####
