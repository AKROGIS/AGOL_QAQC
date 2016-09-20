"""
migrate_user(old, new)
 copy profile (description, tags, thumbnail,...) from old to new,
 set userType (myEsri) of new to match old
 reassign content from old to new (create matching folder names) (test behavior if folder exists)
 reassign owned groups from old to new
 add new user to same groups as old user
 reassign invitations from old user to new user
 reassign notifications from old user to new user
 reassign license from old user to new user
 delete (or disable) old user
 send migration email

delete_user(id):
 get regional admin from users region/program group
 reassign all content to the regional admin user
   put content in folders called owner_folder
 reassign all groups to a 'regional' user
 Revoke all license allocations

Catchup_task (can be done repeatedly, must be run right before cron is run):
 for all accounts:
   activate myESRI
   if user is in AD (with Region/Program code)
     then add user to regional admin's assignee group
     else add user to unaffiliated group, and email the admin to manually assign user to a regional admin
 for all SAML accounts with matching old account:
  migrate_user(old, new)

Nightly Cron task
 for all users whose account was created since the last check
  if user is a new SAML account with email that matches a basic account
   migrate_user(basic, SAML)
  else:
   activate myESRI
   send new user email
   if user is in AD (with Region/Program code)
     then add user to regional admin's assignee group
     else add user to unaffiliated group, and email the admin to manually assign user to a regional admin

 for all SAML users no longer in AD
   delete_user()

 for all non-SAML users
   periodically advise regional admin to review account.

 search items for policy violations
   email user and regional admin
   disable content?

 Needs:
   Identification of responsible regional admin accounts
   Creation of regional groups owned by regional admins
   AD rules to match users to regional admins
   Policy rules (that can be automatically checked)
   new user email content
   tags to programmatically identify/find regional user groups

Discuss:
  Regional admin account: allow headless?
    will get deleted user content/groups
    will get email advisories
  Update profile during migration?
  owner of unaffiliated users group
"""

import portalpy


def mypost(self, path, props):
    postdata = self._postdata()
    postdata.update(props)
    return self.con.post(path, postdata)


portalpy.Portal.mypost = mypost


def get_paged_results(path,
                      post_params=None,
                      max_results=None):
    # max_results is an integer number of results to fetch, None indicates fetch all
    # see http://resources.arcgis.com/en/help/arcgis-rest-api/index.html#/
    #     Common_parameters/02r30000009v000000/ESRI_SECTION1_42D43ABF38FC49F8B9DC6A9BFEA1E235/
    if post_params is None:
        post_params = {}
    post_params['f'] = 'json'
    post_params['start'] = 1
    post_params['num'] = 100 if max_results is None else min(max_results, 100)
    response = con.mypost(path, post_params)
    results = [response]
    count = int(response['num'])
    next_start = int(response['nextStart'])
    max_results = max_results or int(response['total'])
    while next_start != -1 and count < max_results:
        post_params['start'] = next_start
        post_params['num'] = min(100, max_results - count)
        response = con.mypost(path, post_params)
        results.append(response)
        count += int(response['num'])
        next_start = int(response['nextStart'])
    return results


def move_content(from_user, to_user):
    path = 'content/users/' + from_user
    # will only return the first 10 items
    # content = con.mypost(path) # or max 100 items, {'start': 1, 'num': 100})
    # items = content['items']
    # gets all results
    content = get_paged_results(path)
    items = [item for response in content for item in response['items']]
    # reassign items in home folder
    # note: target folder will get created automatically if it does not exist
    props = {'targetUsername': to_user, 'targetFolderName': from_user + '_' + 'home'}
    for item in items:
        path = 'content/users/' + from_user + '/items/' + item['id'] + '/reassign'
        print(path, props)
        # response = con.mypost(path, props)
        # print(response['success'] if response else 'failed')

    for folder in content[0]['folders']:
        path = 'content/users/' + from_user + '/' + folder['id']
        # will only return the first 100 items
        # folderContents = con.mypost(path, {'start': 1, 'num': 100})
        # items = folderContents['items']
        folder_contents = get_paged_results(path)
        items = [item for response in folder_contents for item in response['items']]
        # reassign items in sub folder
        props = {'targetUsername': to_user, 'targetFolderName': from_user + '_' + folder['title']}
        for item in items:
            path = 'content/users/' + from_user + '/' + folder['id'] + '/items/' + item['id'] + '/reassign'
            print(path, props)
            # response = con.mypost(path, props)
            # print(response['success'] if response else 'failed')


if __name__ == '__main__':
    con = portalpy.Portal('https://nps.maps.arcgis.com', 'regan_sarwas@nps.gov', 'xxx')

    old = 'rsarwas'
    new = 'regan_sarwas@nps.gov'
    move_content(old, new)
