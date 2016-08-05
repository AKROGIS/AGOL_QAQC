#### Generate a CSV listing the items in the organization
#### Optionally include a query using ArcGIS Portal API syntax (http://resources.arcgis.com/en/help/arcgis-rest-api/02r3/02r3000000mn000000.htm)
#### Optionally return the size of the item (requires additional API request for each item, default is False)
#### The results will include every item accessible by the credentials provided
#### Example:
#### AGOLCat.py -u myuser -p mypassword -size False -portal https://esri.maps.arcgis.com -file c:\temp\agol.csv


import csv
import argparse
import sys

from agoTools.admin import Admin


def _raw_input(prompt=None, stream=None, input=None):
    # A raw_input() replacement that doesn't save the string in the
    # GNU readline history.
    if not stream:
        stream = sys.stderr
    if not input:
        input = sys.stdin
    prompt = str(prompt)
    if prompt:
        stream.write(prompt)
        stream.flush()
    # NOTE: The Python C API calls flockfile() (and unlock) during readline.
    line = input.readline()
    if not line:
        raise EOFError
    if line[-1] == '\n':
        line = line[:-1]
    return line


parser = argparse.ArgumentParser()
parser.add_argument('-u', '--user')
parser.add_argument('-p', '--password')
parser.add_argument('-q', '--query')
parser.add_argument('-file', '--file')
parser.add_argument('-portal', '--portal')
parser.add_argument('-size', '--bIncludeSize')

args = parser.parse_args()

if args.file == None:
    args.file = _raw_input("CSV path: ")

if args.user == None:
    args.user = _raw_input("Username:")

if args.portal == None:
    args.portal = _raw_input("Portal: ")

args.portal = str(args.portal).replace("http://","https://")

bIncludeSize=False

if (args.bIncludeSize != None) and (args.bIncludeSize.upper() == "TRUE"):
    bIncludeSize=True

agoAdmin = Admin(args.user,args.portal,args.password)

catalog = agoAdmin.AGOLCatalog(args.query,bIncludeSize)

with open(args.file, 'wb') as output:
    csv_writer = csv.writer(output)
    # Write header row.
    header = "id,owner,created,modified,name,title,type,typeKeywords,len_desc,tags,len_snippet,thumbnail,extent,spatialReference,accessInformation,licenseInfo,culture,url,access,size,listed,numComments,numRatings,avgRatings,numViews,itemURL"
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
        utf8_row = [u.encode("utf-8") for u in [x if isinstance(x, unicode) else unicode(x) for x in [n if n else '' for n in row]]]
        csv_writer.writerow(utf8_row)

    print (args.file + " written.")

