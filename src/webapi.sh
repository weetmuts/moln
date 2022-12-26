###############################################################################
# Web api part of moln. Copyright (C) 2022 Fredrik Öhrström license spdx: MIT #
###############################################################################

cmds_WebApis="list-webapi-domains"

function cmd_list_webapi_domains_pre
{
    printf "DOMAIN\tNAME\t\n"
}

function cmd_aws_list_webapi_domains
{
    aws apigatewayv2 get-domain-names | jq -r -c '.Items[].DomainName'
}
