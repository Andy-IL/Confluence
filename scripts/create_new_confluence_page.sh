#!/bin/bash 
echo "#***************************************" 
echo "#Create New Confluence Page" 
echo "#***************************************" 
ATLASSIAN_USER_ID=$1 
ATLASSIAN_API_TOKEN=$2 
CONFLUENCE_URL="https://$3/wiki" 
SPACE=$4 
CONFLUENCE_PARENT_PAGE_ID=$5 
#Ampersand throws Confluence 
TITLE=$(echo "$6" | sed 's/&/\&amp;/g')-$(date +%H%M%S-%d%m%Y)
#Ampersand throws Confluence
CONTENT=$(echo "$7" | sed 's/&/\&amp;/g')

body="{\"type\":\"page\",\"title\":\"$TITLE\",\"ancestors\":[{\"id\":\"$CONFLUENCE_PARENT_PAGE_ID\"}],\"space\":{\"key\":\"$SPACE\"},\"body\":{\"storage\":{\"value\":\"$CONTENT\",\"representation\":\"storage\"}}}" 

echo "#*******************************" 
echo "#Create page - ${TITLE}" 
echo "#*******************************" 
curl -s -X POST -H "Content-Type: application/json" --user $ATLASSIAN_USER_ID:$ATLASSIAN_API_TOKEN  -o new_confluence_page.txt -d "$body" $CONFLUENCE_URL/rest/api/content/ 

echo "#*******************************" 
echo "#New Page ID from above" 
echo "#*******************************" 
cat new_confluence_page.txt | jq -r '.id' > new_confluence_page_id.txt 
echo "New Page ID: " `cat new_confluence_page_id.txt` 
