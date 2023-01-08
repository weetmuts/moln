function cmd_aws_create_vpc
{
    NAME="$1"
    if [ -z "$NAME" ]
    then
        echo "Usage: moln aws create-vpc Name"
        exit 1
    fi
    TAGS="ResourceType=string,Tags='[{Key=Name,Value=\"${NAME}\"}]'"
    echo "Create AWS vpc $NAME $TAGS"
}

function summarize_aws_vpc
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
        LOCATION=

        printf "aws\t$NAME\t$CIDR_BLOCK\t$STATUS\t$ID\t$LOCATION\n"
    fi
}

CMD_AWS_LIST_VPCS='aws ec2 describe-vpcs'
function cmd_aws_list_vpcs
{
    $CMD_AWS_LIST_VPCS | jq -c '.Vpcs[]' | while IFS=$"\n" read -r info; do summarize_aws_vpc "$info" ; done
}
