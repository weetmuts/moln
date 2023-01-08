cmds_SUBNET="list-subnets"

function help_list_subnets
{
    echo "List all subnets."
}

function cmd_list_subnets_pre
{
    printf "CLOUD\tNAME\tCIDR_BLOCK\tSTATUS\tID\t\n"
}
