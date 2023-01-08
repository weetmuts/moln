cmds_USER="list-users"

function help_list_users
{
    echo "List users in cloud account."
}

function cmd_list_users_pre
{
    printf "CLOUD\tNAME\tID\t\n"
}
