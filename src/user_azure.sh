function summarize_azure_user
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        NAME=$(echo "$JSON" | jq -jr '.displayName')
        ID=$(echo "$JSON" | jq -jr '.id')
        printf "azure\t$NAME\t$ID\t\n"
    fi
}

CMD_AZURE_LIST_USERS='az ad user list'
function cmd_azure_list_users
{
    $CMD_AZURE_LIST_USERS | jq -c '.[]' | while IFS=$"\n" read -r info; do summarize_azure_user "$info" ; done
}
