#!/bin/bash
echo "#**********************************************************************************************************************************"
echo "#Add Text / HTML to Existing Confleunce Page "
echo "#**********************************************************************************************************************************"
ATLASSIAN_USER_ID=$1
ATLASSIAN_API_TOKEN=$2
CONFLUENCE_URL="https://$3/wiki"
SPACE=$4
PAGE_ID=$(cat ${5})
CONTENT="<p/>"$6
#Ampersand throws Confleunce
CONTENT=$(echo "$CONTENT" | sed 's/&/\&amp;/g')

echo "#*******************************"
echo "#Get Page Contents - ${PAGE_ID}"
echo "#*******************************"
curl -s -X GET --user $ATLASSIAN_USER_ID:$ATLASSIAN_API_TOKEN -o page_contents.txt  $CONFLUENCE_URL/rest/api/content/$PAGE_ID?expand=body.storage,version,space

echo "#*******************************"
echo "#Modify Page contents locally"
echo "#*******************************"
cat page_contents.txt | jq --arg CONTENT "$CONTENT" '.body.storage.value +=$CONTENT' | jq '.version.number += 1' > modified-page-contents.txt

echo "#*******************************"
echo "#Insert additional contents into page"
echo "#*******************************"
curl -s -X PUT -H "Content-Type: application/json" --user $ATLASSIAN_USER_ID:$ATLASSIAN_API_TOKEN --data @modified-page-contents.txt $CONFLUENCE_URL/rest/api/content/$PAGE_ID
