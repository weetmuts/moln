# Policies part of moln. Copyright (C) 2022 Fredrik Öhrström license spdx: MIT

cmds_Policies="list-policies"

# policies ############################################################################################

function cmd_aws_list_policies
{
    POLICY=$1
    aws iam list-policies --query  "Policies[].Arn"
}
