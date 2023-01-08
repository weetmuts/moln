CMD_AWS_LIST_WEBAPI_DOMAINS='aws apigatewayv2 get-domain-names'
function cmd_aws_list_webapi_domains
{
    $CMD_AWS_LIST_WEBAPI_DOMAINS | jq -r -c '.Items[].DomainName'
}
