function summarize_aws_user
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        NAME=$(echo "$JSON" | jq -jr '.UserName')
        ID=$(echo "$JSON" | jq -jr '.UserId')
        printf "aws\t$NAME\t$ID\t\n"
    fi
}

CMD_AWS_LIST_USERS='aws iam list-users'
function cmd_aws_list_users
{
    $CMD_AWS_LIST_USERS | jq -c '.Users[]' | while IFS=$"\n" read -r info; do summarize_aws_user "$info" ; done
}
