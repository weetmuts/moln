# Copyright (C) 2022-2023 Fredrik Öhrström license spdx: MIT

function cmd_gcloud_create_vm
{
    echo "Not implemented."
}

function cmd_gcloud_start_vm
{
    NAME=$1
    gcloud compute instances start "$NAME"
}

function cmd_gcloud_stop_vm
{
    gcloud compute instances stop "$NAME"
}

function summarize_gcloud_vm {
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ "$verbose" = "true" ]; then echo "$JSON"; fi
    NAME=$(echo "$JSON" | jq -r .name)
    STATUS=$(echo "$JSON" | jq -r .status)
    MACHINETYPE=$(echo "$JSON" | jq -r .machineType)
    ZONE=$(echo "$MACHINETYPE" | grep -Po 'zones/\K.*?(?=/)')
    TYPE=$(echo "$MACHINETYPE" | grep -Po 'machineTypes/\K.*')
    TIMESTAMP=$(echo "$JSON" | jq -r .lastStartTimestamp)
    SINCE=$(duration_since "$TIMESTAMP")
    printf "google\t$NAME\t$STATUS\t$SINCE\t$ZONE\t$TYPE\n"
}


CMD_GCLOUD_LIST_VMS="gcloud compute instances list --format json"
function cmd_gcloud_list_vms
{
    $CMD_GCLOUD_LIST_VMS | jq -c '.[]' | while IFS=$"\n" read -r info; do summarize_gcloud_vm "$info" ; done
}
