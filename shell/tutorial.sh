#!/bin/bash

# simple Manifest for tutorial app (encode with https://www.base64encode.org/)
# {
#	"name":"Tutorial App",
#	"identifier":"eu.ownyourdata.tutorial",
#	"type":"external",
#	"description":"manifest for tutorial app",
#	"permissions":["eu.ownyourdata.tutorial:read",
#				   "eu.ownyourdata.tutorial:write",
#				   "eu.ownyourdata.tutorial:update",
#				   "eu.ownyourdata.tutorial:delete",
#				   "eu.ownyourdata.tutorial.log:read",
#				   "eu.ownyourdata.tutorial.log:write"]
# }
# ew0KCSJuYW1lIjoiVHV0b3JpYWwgQXBwIiwNCgkiaWRlbnRpZmllciI6ImV1Lm93bnlvdXJkYXRhLnR1dG9yaWFsIiwNCgkidHlwZSI6ImV4dGVybmFsIiwNCgkiZGVzY3JpcHRpb24iOiJtYW5pZmVzdCBmb3IgdHV0b3JpYWwgYXBwIiwNCgkicGVybWlzc2lvbnMiOlsiZXUub3dueW91cmRhdGEudHV0b3JpYWw6cmVhZCIsDQoJCQkJICAgImV1Lm93bnlvdXJkYXRhLnR1dG9yaWFsOndyaXRlIiwNCgkJCQkgICAiZXUub3dueW91cmRhdGEudHV0b3JpYWw6dXBkYXRlIiwNCgkJCQkgICAiZXUub3dueW91cmRhdGEudHV0b3JpYWw6ZGVsZXRlIiwNCgkJCQkgICAiZXUub3dueW91cmRhdGEudHV0b3JpYWwubG9nOnJlYWQiLA0KCQkJCSAgICJldS5vd255b3VyZGF0YS50dXRvcmlhbC5sb2c6d3JpdGUiXQ0KfQ==

# wildcard Manifest for tutorial app
# {
#	"name":"Tutorial App",
#	"identifier":"eu.ownyourdata.tutorial",
#	"type":"external",
#	"description":"manifest for tutorial app",
#	"permissions":["eu.ownyourdata.*:read",
#				   "eu.ownyourdata.*:write",
#				   "eu.ownyourdata.*:update",
#				   "eu.ownyourdata.*:delete"]
# }
# ew0KCSJuYW1lIjoiVHV0b3JpYWwgQXBwIiwNCgkiaWRlbnRpZmllciI6ImV1Lm93bnlvdXJkYXRhLnR1dG9yaWFsIiwNCgkidHlwZSI6ImV4dGVybmFsIiwNCgkiZGVzY3JpcHRpb24iOiJtYW5pZmVzdCBmb3IgdHV0b3JpYWwgYXBwIiwNCgkicGVybWlzc2lvbnMiOlsiZXUub3dueW91cmRhdGEuKjpyZWFkIiwNCgkJImV1Lm93bnlvdXJkYXRhLio6d3JpdGUiLA0KCQkiZXUub3dueW91cmRhdGEuKjp1cGRhdGUiLA0KCQkiZXUub3dueW91cmRhdGEuKjpkZWxldGUiXQ0KfQ==

export PIA_URL=http://localhost:8080
export APP_KEY=eu.ownyourdata.tutorial
export APP_SECRET=l1InCBVMY0o31CJDcJKo # !!!update

# get token
export TOKEN=`curl $APP_KEY:$APP_SECRET@${PIA_URL:7:100}/oauth/token -d grant_type=client_credentials | python -c "import json,sys;obj=json.load(sys.stdin);print obj['access_token'];"`
value=$(<tmp.txt)

# write data - simple JSON
export CONTENT="{\"value\": 1}"
curl -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d "$CONTENT" $PIA_URL/api/repos/$APP_KEY/items
# wildcard testing
# OK
# curl -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d "$CONTENT" $PIA_URL/api/repos/eu.ownyourdata.sample/items
# Not OK
# curl -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d "$CONTENT" $PIA_URL/api/repos/eu.sellyourdata.biz/items

# write data - large dataset
# export CONTENT=`head -c 99988 < /dev/zero | tr '\0' '\141'`
# echo $CONTENT > tmp.txt
# value=$(<tmp.txt)
# curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d @- "$PIA_URL/api/repos/$APP_KEY/items" <<tmp.txt
# { "value": "$value"}
# tmp.txt

# update data
export CONTENT='{"id": "1", "value": 0}'
curl -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -X PUT -d "$CONTENT" $PIA_URL/api/repos/$APP_KEY/items

# read data
curl -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -X GET $PIA_URL/api/repos/$APP_KEY/items

# delete data
curl -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -X DELETE $PIA_URL/api/repos/$APP_KEY/items/1

# read data
curl -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -X GET $PIA_URL/api/repos/$APP_KEY/items
