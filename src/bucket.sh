###############################################################################
# Buckets part of moln. Copyright (C) 2022 Fredrik Öhrström license spdx: MIT #
###############################################################################

cmds_Buckets="list-buckets list-bucket-content"

function help_list_buckets {
    echo "list-buckets"
    echo "List storage buckets, ie aws s3/gcloud storage/azure blobs."
}

function cmd_list_buckets_pre
{
    printf "CLOUD\tNAME\t\n"
}

function summarize_aws_bucket
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        NAME=$(echo "$JSON" | jq -jr '.Name')
        printf "aws\t$NAME\t\n"
    fi
}

function cmd_aws_list_buckets
{
    aws s3api list-buckets --output json | jq -c '.Buckets[]' | while IFS=$"\n" read -r info; do summarize_aws_bucket "$info" ; done
}
