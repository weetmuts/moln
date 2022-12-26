##################################################################################
# IP address part of moln. Copyright (C) 2022 Fredrik Öhrström license spdx: MIT #
##################################################################################

cmds_Public_IPs="allocate-ip list-ips bind-ip"

function summarize_aws_ip
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        echo "$1" | jq .
    fi
}

function cmd_list_ips_pre
{
    printf "CLOUD\tNAME\tCIDR_BLOCK\tSTATUS\tID\t\n"
}

function cmd_aws_list_ips
{
    aws ec2 describe-addresses | jq -c '.Addresses[]' | while IFS=$"\n" read -r info; do summarize_aws_ip "$info" ; done
}

function cmd_list_vpcs_ips
{
    #    column -t -s $'\t'
    echo ""
}

function cmd_aws_allocate_ip
{
    NAME="$1"
    if [ -z "$NAME" ]
    then
        echo "Usage: moln aws create-ip Name"
        exit 1
    fi
    TAGS="ResourceType=string,Tags='[{Key=Name,Value=\"${NAME}\"}]'"
    echo aws ec2 allocate-address
}
