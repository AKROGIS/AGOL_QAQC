"""
Generate a CSV listing of the users in a Portal organization.

The results will include every user accessible by the credentials provided.
You must be an administrator in the portal to see user accounts.
fields is a comma separated list of user parameters described in
  http://resources.arcgis.com/en/help/arcgis-rest-api/index.html#/Common_parameters/02r30000009v000000/
fields and portal have good defaults for NPS
username, passsword and file are required, and you will be prompted if not provided.
Example1:
 agol_users.py
Example2:
 agol_users.py -u myuser -p mypassword -fields "email,firstName" -portal https://gisportal.nps.gov -file "c:\agol list.csv"
"""

import csv
import argparse
import sys
import datetime
import getpass

from agoTools.admin import Admin

parser = argparse.ArgumentParser()
parser.add_argument('-u', '--user')
parser.add_argument('-p', '--password')
parser.add_argument('-fields', '--fields')
parser.add_argument('-file', '--file')
parser.add_argument('-portal', '--portal')

args = parser.parse_args()

if args.user is None:
    args.user = raw_input("Username:")

if args.password is None:
    args.password = getpass.getpass()

if args.file is None:
    args.file = raw_input("Path for CSV results: ")

if args.fields is None:
    args.fields = "username,email,region,disabled,firstName,lastName,userType,created,lastLogin,access,role,description"

if args.portal is None:
    args.portal = "https://nps.maps.arcgis.com"

args.portal = str(args.portal).replace("http://", "https://")

print ("Authenticating...")
agoAdmin = Admin(args.user, args.portal, args.password)

print ("Getting Users...")
users = agoAdmin.getUsers()

print ("Formatting Results...")
# remove bad header fields:
fields = args.fields.split(',')
if users:
    for field in list(fields):
        if field not in users[0]:
            print "attribute '{}' not found in the user object".format(field)
            fields.remove(field)

if 'role' in fields:
    roles = agoAdmin.getRoles()
    role_by_id = {}
    for role in roles:
        role_by_id[role['id']] = role['name']

with open(args.file, 'wb') as output:
    csv_writer = csv.writer(output)
    csv_writer.writerow(fields)
    # Write item data.
    for user in users:
        row = [user[field] if field in user else None for field in fields]
        # fix 'role'
        if 'role' in fields:
            role_index = fields.index('role')
            role_id = row[role_index]
            if role_id in role_by_id:
                row[role_index] = role_by_id[role_id]
        # fix favGroupId
        # fix date fields:
        for field in ['lastLogin', 'created', 'modified', ]:
            if field in fields:
                index = fields.index(field)
                timestamp = row[index]
                if timestamp == -1:
                    date = None
                else:
                    try:
                        date = datetime.datetime.fromtimestamp(timestamp / 1e3).isoformat()
                    except Exception, error:
                        print ("{0} {1}".format(timestamp, error))
                        date = None
                row[index] = date

        utf8_row = [u.encode("utf-8") for u in [unicode(n) if n is not None else u'' for n in row]]
        csv_writer.writerow(utf8_row)
    print (args.file + " written.")
