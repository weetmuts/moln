###############################################################################
# Web api part of moln. Copyright (C) 2022 Fredrik Öhrström license spdx: MIT #
###############################################################################

cmds_Apis="list-api-domains"

function cmd_list_api_domains_pre
{
    printf "DOMAIN\tNAME\t\n"
}

function cmd_aws_list_api_domains
{
    aws apigatewayv2 get-domain-names | jq -r -c '.Items[].DomainName'
}

function cmd_list_api_domains
{
    column -t -s $'\t'
}
