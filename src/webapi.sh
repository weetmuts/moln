cmds_WEBAPI="list-webapi-domains"

function help_list_webapi_domains
{
    echo "List domain names mapped to web apis (REST/HTTPs) routers."
}

function cmd_list_webapi_domains_pre
{
    printf "DOMAIN\tNAME\t\n"
}
