CMD_AWS_ASSUME_ROLE='aws sts assume-role --role-arn "arn:aws:iam::${AWS_ACCOUNT}:role/$ROLE" --role-session-name "$SESSION"'
function cmd_aws_assume_role
{
    ROLE="$1"
    SESSION="$2"

    ROLE_ARN=arn:aws:iam::${AWS_ACCOUNT}:role/$ROLE_NAME

    if [ -z "$SESSION" ] || [ -z "$ROLE" ]
    then
        echo "Usage: moln aws assume-role <role> <session>"
        exit 1
    fi
    eval $CMD_AWS_ASSUME_ROLE > session.token
    ROLE_SESSION_NAME=$(jq .AssumedRoleUser.Arn session.token | tr -d '"' | cut -f 2- -d '/')
    echo "Role session ${ROLE_SESSION_NAME} expires $(jq .Credentials.Expiration session.token | tr -d '"')"
    AWS_ACCESS_KEY_ID=$(jq .Credentials.AccessKeyId session.token | tr -d '"') \
    AWS_SECRET_ACCESS_KEY=$(jq .Credentials.SecretAccessKey session.token | tr -d '"') \
    AWS_SESSION_TOKEN=$(jq .Credentials.SessionToken session.token | tr -d '"') \
    bash --rcfile <(echo 'export PS1="${PS1}\[\033[01;31m\]['${ROLE_SESSION_NAME}']\[\033[00m\]\$ "')
}

CMD_AWS_LIST_ROLES='aws iam list-roles'
function cmd_aws_list_roles
{
    $CMD_AWS_LIST_ROLES --query  "Roles[].Arn"
}
