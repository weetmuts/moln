cmds_IP="list-ips"

function help_list_ips
{
    echo "List allocated external ip numbers."
}

function cmd_list_ips_pre
{
    printf "CLOUD\tNAME\tCIDR_BLOCK\tSTATUS\tID\t\n"
}
