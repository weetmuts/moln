# Roles part of moln. Copyright (C) 2022 Fredrik Öhrström license spdx: MIT

cmds_Roles="print-default-role-policy create-role attach-role-policy list-attached-role-policies list-roles assume-role"

## roles ############################################################

function cmd_aws_list_roles
{
    ROLE=$1
    aws iam list-roles --query  "Roles[].Arn"
}

function cmd_aws_assume_role
{
    ROLE_ARN=arn:aws:iam::${AWS_ACCOUNT}:role/$1
    SESSION_NAME=$2
    if [ -z "$SESSION_NAME" ] || [ -z "$ROLE_ARN" ]
    then
        echo "Usage: moln aws assume-role <role> <session_name>"
        exit 1
    fi
    echo "aws sts assume-role --role-arn $ROLE_ARN --role-session-name $SESSION_NAME > session.token"
    aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name "$SESSION_NAME" > session.token
    ROLE_SESSION_NAME=$(jq .AssumedRoleUser.Arn session.token | tr -d '"' | cut -f 2- -d '/')
    echo "Role session ${ROLE_SESSION_NAME} expires $(jq .Credentials.Expiration session.token | tr -d '"')"
    AWS_ACCESS_KEY_ID=$(jq .Credentials.AccessKeyId session.token | tr -d '"') \
    AWS_SECRET_ACCESS_KEY=$(jq .Credentials.SecretAccessKey session.token | tr -d '"') \
    AWS_SESSION_TOKEN=$(jq .Credentials.SessionToken session.token | tr -d '"') \
    bash --rcfile <(echo 'export PS1="${PS1}\[\033[01;31m\]['${ROLE_SESSION_NAME}']\[\033[00m\]\$ "')
}
