function cmd_aws_list_costs
{
cat > /tmp/filters.json <<EOF
{
    "Dimensions": {
        "Key": "SERVICE",
        "Values": [
            "Amazon Elastic Compute Cloud - Compute"
        ]
    }
}
EOF

    aws ce get-cost-and-usage \
    --time-period Start=2022-01-01,End=2023-02-01 \
    --metrics "BlendedCost" \
    --granularity MONTHLY \
    --filter='{ "Dimensions": { "Key": "SERVICE", "Values": [ "Amazon Elastic Compute Cloud - Compute" ] } }' \
    | tee costs.json
}
#    --filter file:///tmp/filters.json \
