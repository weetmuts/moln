# Costs part of moln. Copyright (C) 2022 Fredrik Öhrström license spdx: MIT

cmds_Costs="list-costs"

## costs ########################################################

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
    --time-period Start=2021-12-01,End=2021-12-30 \
    --metrics "BlendedCost" \
    --granularity MONTHLY \
    --filter='{ "Dimensions": { "Key": "SERVICE", "Values": [ "Amazon Elastic Compute Cloud - Compute" ] } }' \
    --group-by "Type=TAG,Key=Customer" | tee costs.json
}
#    --filter file:///tmp/filters.json \
