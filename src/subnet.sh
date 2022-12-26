# Subnet part of moln. Copyright (C) 2022 Fredrik Öhrström license spdx: MIT

cmds_Subnets_inside_a_VPC="create-subnet list-subnets"

## subnets ########################################################

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

function cmd_list_subnets_pre
{
    printf "CLOUD\tNAME\tCIDR_BLOCK\tSTATUS\tID\t\n"
}

function cmd_aws_list_subnets
{
    aws ec2 describe-subnets | jq -c '.Subnets[]' | while IFS=$"\n" read -r info; do summarize_aws_subnet "$info" ; done | sort
}

function cmd_list_subnets_post
{
    column -t -s $'\t'
}
