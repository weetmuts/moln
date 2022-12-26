# User part of moln. Copyright (C) 2022 Fredrik Öhrström license spdx: MIT

cmds_Users="list-users"

## users ########################################################

function cmd_list_users_pre
{
    printf "CLOUD\tNAME\tID\t\n"
}

function summarize_aws_user {
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        NAME=$(echo "$JSON" | jq -jr '.UserName')
        ID=$(echo "$JSON" | jq -jr '.UserId')
        printf "aws\t$NAME\t$ID\t\n"
    fi
}

function cmd_aws_list_users {
    aws iam list-users | jq -c '.Users[]' | while IFS=$"\n" read -r info; do summarize_aws_user "$info" ; done
}

function summarize_azure_user {
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        NAME=$(echo "$JSON" | jq -jr '.displayName')
        ID=$(echo "$JSON" | jq -jr '.id')
        printf "azure\t$NAME\t$ID\t\n"
    fi
}

function cmd_azure_list_users {
    az ad user list | jq -c '.[]' | while IFS=$"\n" read -r info; do summarize_azure_user "$info" ; done
}

function summarize_gcloud_user {
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        NAME=$(echo "$JSON" | jq -jr '.displayName')
        ID=$(echo "$JSON" | jq -jr '.uniqueId')
        printf "gcloud\t$NAME\t$ID\t\n"
    fi
}

function cmd_gcloud_list_users {
    gcloud iam service-accounts --format=json list | jq -c '.[]' | while IFS=$"\n" read -r info; do summarize_gcloud_user "$info" ; done
}
