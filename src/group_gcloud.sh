function summarize_gcloud_group
{
    JSON="$1"
    NAME=$(echo "$JSON" | jq -jr '.GroupName')
    printf "gcloud\t$NAME\t\n"
}

CMDx_GCLOUD_LIST_GROUPS='gcloud iam list-grantable-roles'
function cmdx_gcloud_list_groups
{
    $CMD_GCLOUD_LIST_GROUPS | jq -c '.[]' | while IFS=$"\n" read -r info; do summarize_azure_group "$info" ; done
}
