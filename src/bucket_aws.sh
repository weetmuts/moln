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

CMD_AWS_LIST_BUCKETS='aws s3api list-buckets --output json'
function cmd_aws_list_buckets
{
    $CMD_AWS_LIST_BUCKETS | jq -c '.Buckets[]' | while IFS=$"\n" read -r info; do summarize_aws_bucket "$info" ; done
}
