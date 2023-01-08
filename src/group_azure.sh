function summarize_azure_group
{
    JSON="$1"
    NAME=$(echo "$JSON" | jq -jr '.GroupName')
    printf "azure\t$NAME\t\n"
}

CMD_AZURE_LIST_GROUPS='az ad group list'
function cmd_aws_list_groups
{
    $CMD_AZURE_LIST_GROUPS | jq -c '.[]' | while IFS=$"\n" read -r info; do summarize_azure_group "$info" ; done
}
