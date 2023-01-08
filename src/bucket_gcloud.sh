function summarize_gcloud_bucket
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        NAME=$(echo "$JSON" | jq -jr '.Name')
        printf "aws\t$NAME\t\n"
    fi
}

function cmd_gcloud_list_buckets
{
    echo "Not implemented"
}
