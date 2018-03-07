#!/bin/sh

###########
# This script was originally intended to be used as a post-build action for a jenkins
# build job. It pulls the changelog from the jenkins job and updates each Jira ticket
# found with the current build number.
#
## IMPORTANT:
# This script is also dependent on the get_jiras.py script that pulls 
#
## ASSUMPTIONS:
#   You are using both Jira and Jenkins
#   You have set the following environment variables:
#       JIRA_USERNAME
#       JIRA_PASSWORD
#       BUILD_NUMBER
#
#
## USAGE INSTRUCTIONS:
# Run this script as a post-build step. The get_jiras.py script needs to be in the same
# directory as this script.
#   ./update_jira.sh 
###########

JIRA_URL="https://jira.yourcompanydomain.com"
BUILD_URL="https://buildmachine.yourcompanydomain.net/view/project_folder/job/project_name/${BUILD_NUMBER}/api/json"

if [ -z "${JIRA_USERNAME}" ]; then
    echo "JIRA_USERNAME environment variable is unset or empty, skipping update JIRA process."
    exit 0
fi

set -x # echo on

# retrieve build_json.txt
curl \
    -sS \
    -o build_json.txt \
    -u ${JIRA_USERNAME}:${JIRA_PASSWORD} \
    ${BUILD_URL}

# parse build_json.txt
JIRAS=`get_jiras.py`

for jira in $JIRAS; do
    echo "Setting JIRA ${jira} build fixed to ${BUILD_NUMBER}"
    curl \
        --silent \
        -D- \
        -u ${JIRA_USERNAME}:${JIRA_PASSWORD} \
        -X PUT \
        --data "{ \"fields\": { \"customfield_10094\":\"${BUILD_NUMBER}\" } }" \
        -H "Content-Type: application/json" \
        ${JIRA_URL}/rest/api/2/issue/${jira}
done
