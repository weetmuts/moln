function summarize_aws_ip
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ -n "$JSON" ]
    then
        echo "$1" | jq .
    fi
}

CMD_AWS_LIST_IPS='aws ec2 describe-addresses'
function cmd_aws_list_ips
{
    $CMD_AWS_LIST_IPS | jq -c '.Addresses[]' | while IFS=$"\n" read -r info; do summarize_aws_ip "$info" ; done
}
