function summarize_azure_bucket
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        NAME=$(echo "$JSON" | jq -jr '.Name')
        printf "aws\t$NAME\t\n"
    fi
}

function cmd_azure_list_buckets
{
    echo "Not implemented"
}
