function summarize_aws_subnet
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        NAME='Not set!'
        if [ "$(echo "$JSON" | jq -jr '.Tags')" != "null" ]
        then
            NAME=$(echo "$JSON" | jq -jr '(.Tags[] | select (.Key == "Name") | .Value)')
        fi
        ID=$(echo "$JSON" | jq -jr '.VpcId')
        STATUS=$(echo "$JSON" | jq -jr '.State')
        CIDR_BLOCK=$(echo "$JSON" | jq -jr '.CidrBlock')
        IS_DEFAULT=
        if [ "$(echo "$JSON" | jq -jr '.IsDefault')" = "true" ]
        then
            IS_DEFAULT=DEFAULT
        fi

        printf "aws\t$NAME\t$CIDR_BLOCK\t$STATUS\t$ID\t$IS_DEFAULT\n"
    fi
}

CMD_AWS_LIST_SUBNETS='aws ec2 describe-subnets'
function cmd_aws_list_subnets
{
    $CMD_AWS_LIST_SUBNETS | jq -c '.Subnets[]' | while IFS=$"\n" read -r info; do summarize_aws_subnet "$info" ; done | sort
}
