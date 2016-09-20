#migrate_user(old, new)
# copy profile (description, tags, thumbnail,...) from old to new,
# set userType (myEsri) of new to match old
# reassign content from old to new (create matching folder names) (test behavior if folder exists)
# reassign owned groups from old to new
# add new user to same groups as old user
# reassign invitations from old user to new user
# reassign notifications from old user to new user
# reassign license from old user to new user
# delete (or disable) old user
# send migration email

#delete_user(id):
# get regional admin from users region/program group
# reassign all content to the regional admin user
#   put content in folders called owner_folder
# reassign all groups to a 'regional' user
# Revoke all license allocations

#Catchup_task (can be done repeatedly, must be run right before cron is run):
# for all accounts:
#   activate myESRI
#   if user is in AD (with Region/Program code)
#     then add user to regional admin's assignee group
#     else add user to unaffiliated group, and email the admin to manually assign user to a regional admin
# for all SAML accounts with matching old account:
#  migrate_user(old, new)
#
#Nightly Cron task
# for all users whose account was created since the last check
#  if user is a new SAML account with email that matches a basic account
#   migrate_user(basic, SAML)
#  else:
#   activate myESRI
#   send new user email
#   if user is in AD (with Region/Program code)
#     then add user to regional admin's assignee group
#     else add user to unaffiliated group, and email the admin to manually assign user to a regional admin
#
# for all SAML users no longer in AD
#   delete_user()
#
# for all non-SAML users
#   periodically advise regional admin to review account.
#
# search items for policy violations
#   email user and regional admin
#   disable content?

# Needs:
#   Identification of responsible regional admin accounts
#   Creation of regional groups owned by regional admins
#   AD rules to match users to regional admins
#   Policy rules (that can be automatically checked)
#   new user email content
#   tags to programmatically identify/find regional user groups

#Discuss:
#  Regional admin account: allow headless?
#    will get deleted user content/groups
#    will get email advisories
#  Update profile during migration?
#  owner of unaffiliated users group


def getPagedResults(path,
                    postParams={},
                    maxResults=None):
    # maxResults is an integer number of results to fetch, None indicates fetch all
    # see http://resources.arcgis.com/en/help/arcgis-rest-api/index.html#/Common_parameters/02r30000009v000000/ESRI_SECTION1_42D43ABF38FC49F8B9DC6A9BFEA1E235/
    postParams['f'] = 'json'
    postParams['start'] = 1
    postParams['num'] = 100 if maxResults is None else min(maxResults, 100)
    response = con.mypost(path, postParams)
    results = [response]
    count = int(response['num'])
    nextStart = int(response['nextStart'])
    maxResults = maxResults or int(response['total'])
    while nextStart != -1 and count < maxResults:
        postParams['start'] = nextStart
        postParams['num'] = min(100, maxResults - count)
        response = con.mypost(path, postParams)
        results.append(response)
        count += int(response['num'])
        nextStart = int(response['nextStart'])
    return results



import portalpy

def mypost(self, path, props):
  postdata = self._postdata()
  postdata.update(props)
  return self.con.post(path, postdata)

portalpy.Portal.mypost = mypost

con = portalpy.Portal('https://nps.maps.arcgis.com', 'regan_sarwas@nps.gov', 'xxx')

fromUser = 'rsarwas'
toUser = 'regan_sarwas@nps.gov'


path = 'content/users/' + fromUser
# will only return the first 10 items
# content = con.mypost(path) # or max 100 items, {'start': 1, 'num': 100})
# items = content['items']
# gets all results
content = getPagedResults(path)
items = [item for response in content for item in response['items']]
# reassign items in home folder
# note: target folder will get created automatically if it does not exist
props = {'targetUsername': toUser, 'targetFolderName': fromUser + '_' + 'home'}
for item in items:
  path = 'content/users/'+ fromUser + '/items/' + item['id'] + '/reassign'
  # print(path, props)
  resp = con.mypost(path, props)
  print(resp['success'] if resp else 'failed')


for folder in content[0]['folders']:
    path = 'content/users/' + fromUser + '/' + fid
  # will only return the first 100 items
  # folderContents = con.mypost(path, {'start': 1, 'num': 100})
  # items = folderContents['items']
  folderContents = getPagedResults(path)
  items = [item for response in folderContents for item in response['items']]
  # reassign items in sub folder
  props = {'targetUsername': toUser, 'targetFolderName': fromUser + '_' + folder['title']}
  for item in items:
    path = 'content/users/'+ fromUser +'/' + folder['id'] + '/items/' + item['id'] + '/reassign'
    # print(path, props)
    resp = con.mypost(path, props)
    print(resp['success'] if resp else 'failed')
