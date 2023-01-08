cmds_DNS="list-hosted-zones list-dns-records upsert-dns-record remove-dns-record list-domains"

function help_list_hosted_zones
{
    echo "List zones the dns is configured to serve."
}

function help_list_dns_records
{
    echo "List dns records in a zone."
}

function help_list_domains
{
    echo "List dns domains."
}

function help_upsert_dns_record
{
    echo "Insert or update a dns record."
}

function help_remove_dns_record
{
    echo "Remove a dns record."
}

function cmd_list_hosted_zones_pre
{
    printf "CLOUD\tDOMAIN\tPRIVATE\tID\t\n"
}

function cmd_list_dns_records_pre
{
    printf "CLOUD\tDOMAIN\tTYPE\tTTL\tIP\t\n"
}

function cmd_list_domains_pre
{
    printf "CLOUD\tDOMAIN\tAUTO_RENEW\tTRANSFER_LOCK\tEXPIRES\t\n"
}
