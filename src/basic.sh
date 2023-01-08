cmds_BASIC="whoami"

function help_whoami
{
    echo "Display active account/identity."
}

CMD_AWS_WHOAMI="aws sts get-caller-identity"
function cmd_aws_whoami
{
    $CMD_AWS_WHOAMI
}

CMD_AZURE_WHOAMI="az account list"
function cmd_azure_whoami
{
    $CMD_AZURE_WHOAMI
}

CMD_GCLOUD_WHOAMI="gcloud config list"
function cmd_gcloud_whoami
{
    $CMD_GCLOUD_WHOAMI
}
