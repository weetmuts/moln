# Copyright (C) 2022-2023 Fredrik Öhrström license spdx: MIT

function cmd_azure_start_vm
{
    NAME=$1
    az vm start --resource-group Norge --name "$NAME" --verbose
}

function cmd_azure_stop_vm
{
    az vm deallocate --resource-group Norge --name "$NAME" --verbose
}


function summarize_azure_vm
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ "$verbose" = "true" ]; then echo "$JSON"; fi
    NAME=$(echo "$JSON" | jq -r .name)
    STATUS=$(echo "$JSON" | jq -r .powerState)
    TYPE=$(echo "$JSON" | jq -r .hardwareProfile.vmSize)
    ZONE=$(echo "$JSON" | jq -r .location)
    TIMESTAMP=$(echo "$JSON" | grep -Po '"creationTimestamp":"\K.*?(?=")')
    SINCE=$(duration_since "$TIMESTAMP")
    PUBLIC_IPS=$(echo "$JSON" | jq -r .publicIps)
    printf "azure\t$NAME\t$STATUS\t$ZONE\t$TYPE\t$PUBLIC\tIPS\n"
}

CMD_AZURE_LIST_VMS="az vm list -d"
function cmd_azure_list_vms
{
    $CMD_AZURE_LIST_VMS | jq -c '.[]' | while IFS=$"\n" read -r info; do summarize_azure_vm "$info" ; done
}

function cmd_azure_ssh_to_vm
{
    SERVER=$1
    ssh azureuser@$(az vm show -d -g Norge -n $SERVER --query publicIps | tr -d '"')
}

CMD_AZURE_CREATE_VM_FROM_TEMPLATE='az foo bar ${TEMPLATE_NAME} ${NAME}'
function cmd_azure_create_vm_from_template
{
    NAME="$1"
    TEMPLATE_NAME="$2"
    eval CMD="$CMD_AWS_CREATE_VM_FROM_TEMPLATE"

    echo "Successfully created ${NAME} look in ${NAME}.json ${NAME}.ip"
}
