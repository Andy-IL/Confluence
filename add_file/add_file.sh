#!/bin/bash
echo "#**********************************************************************************************************************************"
echo "#Add File to Existing Confleunce Page"
echo "#**********************************************************************************************************************************"
ATLASSIAN_USER_ID=$1
ATLASSIAN_API_TOKEN=$2
CONFLUENCE_URL="https://$3/wiki"
SPACE=$4
PAGE_ID=$(cat ${5})
FILE_TITLE=$6
FILE_FOLDER=$7
FILE_NAME=$8
FILE_TYPE=$9

if [ "$FILE_TYPE" = "image" ]; then
    	CONTENT="<h2>${FILE_TITLE}</h2><ac:image ac:align=\"center\" ac:layout=\"center\" ac:original-height=\"600\" ac:original-width=\"800\"><ri:attachment ri:filename=\"${FILE_NAME}\" ri:version-at-save=\"1\" /></ac:image><p />"
else
	CONTENT="<h2>${FILE_TITLE}</h2><ac:structured-macro ac:name=\"view-file\" ac:schema-version=\"1\" ac:macro-id=\"a38cb28a-ee15-4436-8fd7-f63fab7980ee\"><ac:parameter ac:name=\"name\"><ri:attachment ri:filename=\"${FILE_NAME}\" /></ac:parameter><ac:parameter ac:name=\"height\">250</ac:parameter></ac:structured-macro>"
fi

echo "#*******************************"
echo "#Insert File into page - Hidden not yet visible in page"
echo "#*******************************"
curl -s -X PUT --user $ATLASSIAN_USER_ID:$ATLASSIAN_API_TOKEN -H "X-Atlassian-Token: nocheck" -F "file=@${FILE_FOLDER}${FILE_NAME}" -F "comment=FileattachedviaRESTAPI" -o file_insert.txt "$CONFLUENCE_URL/rest/api/content/$PAGE_ID/child/attachment"
ls -al 
cat file_insert.txt
echo "#*******************************"
echo "#Get Page Contents"
echo "#*******************************"
curl -s -X GET --user $ATLASSIAN_USER_ID:$ATLASSIAN_API_TOKEN -o page_contents.txt  $CONFLUENCE_URL/rest/api/content/$PAGE_ID?expand=body.storage,version,space

echo "#*******************************"
echo "#Modify Page contents locally"
echo "#*******************************"
cat page_contents.txt | jq --arg CONTENT "$CONTENT" '.body.storage.value +=$CONTENT' | jq '.version.number += 1' > modified-page-contents.txt

echo "#*******************************"
echo "#Insert File into page"
echo "#*******************************"
curl -s -X PUT -H "Content-Type: application/json" --user $ATLASSIAN_USER_ID:$ATLASSIAN_API_TOKEN --data @modified-page-contents.txt -o file-insert-results.txt $CONFLUENCE_URL/rest/api/content/$PAGE_ID
