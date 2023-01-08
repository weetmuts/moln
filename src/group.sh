cmds_GROUP="list-groups list-groups-for-user"

function help_list_groups
{
    echo "List iam groups."
}

function cmd_list_groups_pre
{
    printf "CLOUD\tNAME\t\n"
}

function help_list_groups_for_user
{
    echo "List groups to which a user belongs."
}
