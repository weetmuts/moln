function summarize_azure_vpc
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        NAME=$(echo "$JSON" | jq -jr '.name')
        LOCATION=$(echo "$JSON" | jq -jr '.location')
        ID=$(echo "$JSON" | jq -jr '.id' | cut -f 5,9 -d '/')
        STATUS=$(echo "$JSON" | jq -jr '.provisioningState')
        CIDR_BLOCK=$(echo "$JSON" | jq -jr .addressSpace.addressPrefixes[])

        printf "azure\t$NAME\t$CIDR_BLOCK\t$STATUS\t$ID\t$LOCATION\n"
    fi
}

CMD_AZURE_LIST_VPCS='az network vnet list'
function cmd_azure_list_vpcs
{
    $CMD_AZURE_LIST_VPCS | jq -c '.[]' | while IFS=$"\n" read -r info; do summarize_azure_vpc "$info" ; done
}
