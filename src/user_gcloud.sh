function summarize_gcloud_user
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        NAME=$(echo "$JSON" | jq -jr '.displayName')
        ID=$(echo "$JSON" | jq -jr '.uniqueId')
        printf "gcloud\t$NAME\t$ID\t\n"
    fi
}

CMD_GCLOUD_LIST_USERS='gcloud iam service-accounts --format=json list'
function cmd_gcloud_list_users
{
    $CMD_GCLOUD_LIST_USERS | jq -c '.[]' | while IFS=$"\n" read -r info; do summarize_gcloud_user "$info" ; done
}
