function summarize_aws_group
{
    JSON="$1"
    NAME=$(echo "$JSON" | jq -jr '.GroupName')
    printf "aws\t$NAME\t\n"
}

CMD_AWS_LIST_GROUPS=' aws iam list-groups'
function cmd_aws_list_groups
{
    $CMD_AWS_LIST_GROUPS | jq -c '.Groups[]' | while IFS=$"\n" read -r info; do summarize_aws_group "$info" ; done
}
