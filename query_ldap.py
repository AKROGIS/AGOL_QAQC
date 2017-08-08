"""
ldap requires installation of python-ldap.
typically this could be done with pip, but It relies on the openldap libraries not available on windows
I was able to download a whl (python precompiled binary installation file) from
http://www.lfd.uci.edu/~gohlke/pythonlibs/,  and install with
\path\to\pip install .\python_ldap-2.4.25-cp27-none-win32.whl
"""
# from __future__ import absolute_import, division, print_function, unicode_literals
import ldap
import sys
import getpass
import csv


def print_result(ldap_results):
    for result in ldap_results:
        for dn, attrs in result:
            print(dn)
            for k, v in attrs.items():
                if len(v) == 1:
                    v = v[0]
                print("   ", k, ":", v)


# userEmailAddress = "XXX@nps.gov"
# userEmailAddress = "XXX@nps.gov"
# base_dn = "OU=AKR,DC=nps,DC=doi,DC=net"
# base_dn = "OU=nps,DC=doi,DC=net"
# base_dn = "DC=nps,DC=doi,DC=net" # "", "nps"
# base_dn = "DC=nps,DC=doi,DC=net"
# filter = "(&(gidNumber=123456)(objectClass=posixAccount))"
# filter = "(mail=" + userEmailAddress + ")"
# filter = '(mail=*)'
# filter = '(objectclass=person)'
# filter = "(mail=*nps.gov)"
#  filter = "(cn=*)"
# filter = "(|(givenName=*)(mail=" + userEmailAddress + "))"
# filter = "(ou=AKR)"

# attrs = ["cn","mail","sn","givenName","telephoneNumber","company","title"]
# attrs = None  # get all attributes
# attrs = ['mail']
# Bind to the server


con = ldap.initialize('ldap://xxx.nps.doi.net:389')
con.protocol_version = ldap.VERSION3

# bind_dn = r"CN=Regan E. Sarwas,OU=Permanents,OU=Users,OU=OU_AKRO,OU=AKR,DC=nps,DC=doi,DC=net"
bind_dn = r"John Q. Public"
pw = 'xxx'
if not pw:
    pw = getpass.getpass('Password:')
try:
    res = con.simple_bind_s(bind_dn, pw)
    # print(res)
    print("Authenticated")
except ldap.INVALID_CREDENTIALS:
    print("Your username or password is incorrect.")
    sys.exit(0)
except ldap.LDAPError as e:
    print("LDAPError", e)
    sys.exit(0)


base_dn = 'OU=DEN,DC=nps,DC=doi,DC=net'
attrs = None # ['mail','userPrincipalName']
filter = '(mail=XXXX@nps.gov)'
ldap_result = con.search_st(base_dn, ldap.SCOPE_SUBTREE, filter, attrs, False, 10)
print(ldap_result)
"""
with open('nps_emails.csv','wb') as f:
    total = 0
    csv_writer = csv.writer(f)
    csv_writer.writerow(['email', 'login', 'region', 'cn'])
    for region in ['AKR', 'DEN', 'HQ', 'IMR', 'MWR', 'NCR', 'NER', 'PWR', 'SER', 'Move']:
        for template in ['OU={0},DC=nps,DC=doi,DC=net', 'OU={0},OU=Shared Mailboxes,OU=Messaging,DC=nps,DC=doi,DC=net']:
            base_dn = template.format(region)
            attrs = ['mail', 'userPrincipalName']
            # Need to break it into chunks because several regions have too many results (>5000?) for a single query
            for filter in ['(&(mail=*)(sn=*a*))', '(&(mail=*)(!(sn=*a*)))']:
                print('Searching {0} ...'.format(region))
                try:
                    ldap_result = con.search_st(base_dn, ldap.SCOPE_SUBTREE, filter, attrs, False, 10)
                    # print(ldap_result)
                    count = len(ldap_result)
                    total += count
                    print(region, count, total)
                    for cn, d in ldap_result:
                        login = d['userPrincipalName'][0] if 'userPrincipalName' in d else ''
                        # print([d['mail'][0], login, region, cn])
                        csv_writer.writerow([d['mail'][0], login, region, cn])
                except ldap.LDAPError as e:
                    print("LDAPError", e)
"""
con.unbind_s()
