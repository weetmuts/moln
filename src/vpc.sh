cmds_VPC="create-vpc list-vpcs"

function help_list_vpcs
{
    echo "List virtual private clouds/networks, aka vpc:s and vnets."
}

function cmd_list_vpcs_pre
{
    printf "CLOUD\tNAME\tCIDR_BLOCK\tSTATUS\tID\tLOCATION\n"
}
