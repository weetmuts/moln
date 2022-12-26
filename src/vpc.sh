# Vpc part of moln. Copyright (C) 2022 Fredrik Öhrström license spdx: MIT

cmds_Virtual_Private_Clouds="create-vpc list-vpcs"

## vpc ########################################################

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
        IS_DEFAULT=
        if [ "$(echo "$JSON" | jq -jr '.IsDefault')" = "true" ]
        then
            IS_DEFAULT=DEFAULT
        fi

        printf "aws\t$NAME\t$CIDR_BLOCK\t$STATUS\t$ID\t$IS_DEFAULT\n"
    fi
}

function cmd_list_vpcs_pre
{
    printf "CLOUD\tNAME\tCIDR_BLOCK\tSTATUS\tID\t\n"
}

function cmd_aws_list_vpcs
{
    aws ec2 describe-vpcs | jq -c '.Vpcs[]' | while IFS=$"\n" read -r info; do summarize_aws_vpc "$info" ; done
}

function cmd_list_vpcs_post
{
    column -t -s $'\t'
}
