import ldap
import sys
import getpass


l = ldap.initialize('ldap://inpakrodc02.nps.doi.net:389')
binddn = r"CN=Regan E. Sarwas,OU=Permanents,OU=Users,OU=OU_AKRO,OU=AKR,DC=nps,DC=doi,DC=net"
pw = getpass.getpass('Password:')
basedn = "OU=AKR,DC=nps,DC=doi,DC=net"
searchFilter = "(&(gidNumber=123456)(objectClass=posixAccount))"
searchAttribute = ["mail","department"]
#this will scope the entire subtree under UserUnits
searchScope = ldap.SCOPE_SUBTREE
#Bind to the server
try:
    l.protocol_version = ldap.VERSION3
    l.simple_bind_s(binddn, pw)
except ldap.INVALID_CREDENTIALS:
  print "Your username or password is incorrect."
  sys.exit(0)
except ldap.LDAPError, e:
  if type(e.message) == dict and e.message.has_key('desc'):
      print e.message['desc']
  else:
      print e
  sys.exit(0)
try:
    ldap_result_id = l.search(basedn, searchScope, searchFilter, searchAttribute)
    result_set = []
    while 1:
        result_type, result_data = l.result(ldap_result_id, 0)
        if (result_data == []):
            break
        else:
            ## if you are expecting multiple results you can append them
            ## otherwise you can just wait until the initial result and break out
            if result_type == ldap.RES_SEARCH_ENTRY:
                result_set.append(result_data)
    print result_set
except ldap.LDAPError, e:
    print e
l.unbind_s()
