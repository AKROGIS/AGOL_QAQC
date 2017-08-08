import json

from agoTools.admin import Admin

def fix_basemap(item):
    new_item = {
        'id': item['id'],
        'data': '',
        'thumbnail': item['thumbnail'],
        'metadata': '',
        'item_properties': {
            'type' : item['type'],
            'typeKeywords': item['typeKeywords'],
            'description': item['description'],
            'title': item['title'],
            'url': item['url'],
            'tags': item['tags'],
            'snippet': item['snippet'],
            'accessInformation': item['accessInformation'],
            'spatialReference': item['spatialReference'],
            'accessInformation': item['accessInformation'],
            'licenseInfo': item['licenseInfo'],
            'culture': item['culture'],
            'access': item['access'],
            'commentsEnabled': True,
            'culture': item['culture'],
        }
    }
    if item['type'] == 'Web Map':
        print "getting data for " + str(item['title'])
        new_item['data'] = json.loads(agoAdmin.getData(item['id']))
    return new_item

args = {}
args_portal = "https://nps.maps.arcgis.com"
args_user = "xxx"
args_password = "xxx"

print ("Authenticating...")
agoAdmin = Admin(args_user, args_portal, args_password)

basemap_group = agoAdmin.findGroup("NPS Basemaps and Services")
#print json.dumps(basemap_group)
basemap_groupid = basemap_group['id']
#print basemap_groupid

basemap_catalog = agoAdmin.AGOLGroupCatalog(basemap_group['id'])

#basemap_catalog = agoAdmin.AGOLCatalog("id:5d2bfa736f8448b3a1708e1f6be23eed",False,None,True)
#print(json.dumps(basemap_catalog[0].dict, indent=2))
#print(json.dumps([basemap.dict for basemap in basemap_catalog], indent=2))
print(json.dumps([fix_basemap(basemap.dict) for basemap in basemap_catalog], indent=2))
#print basemap_catalog

#basemap_items = agoAdmin.AGOLCatalog(None,None,basemap_catalog)

#print len(json.dumps(basemap_items))
