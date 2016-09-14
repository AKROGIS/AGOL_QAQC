"""
Generate a CSV listing the items in the organization

Optionally include a query using ArcGIS Portal API syntax
        (http://resources.arcgis.com/en/help/arcgis-rest-api/02r3/02r3000000mn000000.htm)
Optionally return the size of the item (requires additional API request for each item, default is False)
The results will include every item accessible by the credentials provided
Example1:
 AGOLCat.py
Example2:
 AGOLCat.py -u myuser -p mypassword -size False -portal https://esri.maps.arcgis.com -file c:\temp\agol.csv
"""

import csv
import argparse
import getpass
import agoTools.admin

parser = argparse.ArgumentParser()
parser.add_argument('-u', '--user')
parser.add_argument('-p', '--password')
parser.add_argument('-q', '--query')
parser.add_argument('-file', '--file')
parser.add_argument('-portal', '--portal')
parser.add_argument('-size', '--bIncludeSize')

args = parser.parse_args()

if args.user is None:
    args.user = raw_input("Username:")

if args.password is None:
    args.password = getpass.getpass()

if args.file is None:
    args.file = raw_input("Path for CSV results: ")

if args.portal is None:
    args.portal = "https://nps.maps.arcgis.com"
args.portal = str(args.portal).replace("http://", "https://")

bIncludeSize = False
if (args.bIncludeSize is not None) and (args.bIncludeSize.upper() == "TRUE"):
    bIncludeSize = True


print ("Authenticating...")
agoAdmin = agoTools.admin.Admin(args.user, args.portal, args.password)

print ("Getting Catalog...")
catalog = []
try:
    catalog = agoAdmin.AGOLCatalog(args.query, bIncludeSize)
except Exception, e:
    print "Failure.", e.message

print ("Formatting Output...")
with open(args.file, 'wb') as output:
    csv_writer = csv.writer(output)
    # Write header row.
    header = ("id,owner,created,modified,name,title,type,typeKeywords,len_desc,tags,len_snippet,"
              "thumbnail,extent,spatialReference,accessInformation,licenseInfo,culture,url,access,"
              "size,listed,numComments,numRatings,avgRatings,numViews,itemURL")
    csv_writer.writerow(header.split(','))
    # Write item data.
    for r in catalog:
        row = [
            r.id,
            r.owner,
            r.created,
            r.modified,
            r.name,
            r.title,
            r.type,

            ';'.join(r.typeKeywords),
            len(r.description) if r.description else 0,
            ';'.join(r.tags),
            len(r.snippet) if r.snippet else 0,
            r.thumbnail,
            '',

            r.spatialReference,
            r.accessInformation,
            r.licenseInfo,
            r.culture,

            r.url,
            r.access,
            r.size,

            r.listed,
            r.numComments,
            r.numRatings,
            r.avgRating,
            r.numViews,

            r.itemURL
        ]
        utf8_row = [u.encode("utf-8") for u in [unicode(x) for x in [n if n else '' for n in row]]]
        csv_writer.writerow(utf8_row)

    print (args.file + " written.")
