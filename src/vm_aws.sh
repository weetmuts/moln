function cmd_aws_to_vm_id
{
    A="$1"
    if [[ $A == i-* ]]
    then
        # The argument is already an id.
        echo $A
    fi
    NAME="$1"
    aws ec2 describe-instances --filters "Name=tag:Name,Values=${NAME}" | jq -r .Reservations[].Instances[].InstanceId
}

function summarize_aws_vm_template
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ "$debug" = "true" ]; then echo "$JSON"; fi
    NAME=$(echo "$JSON" | jq -jr '.LaunchTemplateName')
    ID=$(echo "$JSON" | jq -jr '.LaunchTemplateId')
    CREATION=$(echo "$JSON" | jq -jr '.CreateTime')
    printf "aws\t$ID\t$NAME\t$CREATION\t\n"
}

CMD_AWS_LIST_VM_TEMPLATES='aws ec2 describe-launch-templates'
function cmd_aws_list_vm_templates
{
    $CMD_AWS_LIST_VM_TEMPLATES | jq -c '.LaunchTemplates[]' | while IFS=$"\n" read -r info; do summarize_aws_vm_template "$info" ; done | sort -k3
}

function summarize_aws_vm_image
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ "$debug" = "true" ]; then echo "$JSON"; fi
    NAME=$(echo "$JSON" | jq -jr '.Name')
    ID=$(echo "$JSON" | jq -jr '.ImageId')
    CREATION=$(echo "$JSON" | jq -jr '.CreationDate')
    DEPRECATION=$(echo "$JSON" | jq -jr '.DeprecationTime')
    DESCRIPTION=$(echo "$JSON" | jq -jr '.Description')
    printf "aws\t$ID\t$CREATION\t$NAME\t$DESCRIPTION\t$DEPRECATION\t\n"
}

function cmd_aws_list_vm_images
{
    OS=$1
    VERSION=$2
    ARCH=$3

    if [ -z "$OS" ]; then echo "You have to specify an os! (e.g. ubuntu RHEL debian)" ; exit 1; fi;
    if [ -z "$VERSION" ]; then echo "You have to specify a version! (e.g. 22.04 8.6.0 11)" ; exit 1; fi;
    if [ -z "$ARCH" ]; then ARCH="x86_64"; fi

    CMD="aws ec2 describe-images \
            --owners self amazon \
            --filters \"Name=architecture,Values=${ARCH}\" \"Name=name,Values=*${OS}*${VERSION}*\" \"Name=root-device-type,Values=ebs\" "
#            --query 'Images[*].[ImageId,CreationDate,Name,Description,DeprecationTime]' --output text \
#            | sort -k2 -r \
#            | head -n1"

    if [ "$verbose" = "true" ]; then echo "$CMD" | tr -s ' ' ; fi
    eval "$CMD" | jq -c '.Images[]' | while IFS=$"\n" read -r info; do summarize_aws_vm_image "$info" ; done | sort -k3
}

function cmd_aws_show_vm_image
{
    IMAGE=$1

    aws ec2 describe-images \
        --image-ids ${IMAGE}
}

CMD_AWS_CREATE_VM_FROM_TEMPLATE='aws ec2 run-instances
--launch-template LaunchTemplateName=${TEMPLATE_NAME}
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${NAME}}]" '
function cmd_aws_create_vm_from_template
{
    NAME="$1"
    TEMPLATE_NAME="$2"
    eval CMD="$CMD_AWS_CREATE_VM_FROM_TEMPLATE"

    if [ "$verbose" = "true" ]; then echo "$CMD" | tr -s ' ' ; fi
    eval "$CMD" > ${NAME}.json

    if [ "$?" != "0" ]
    then
        echo "Failed to create $NAME"
        rm ${NAME}.json
        exit 1
    fi

    jq -r .Instances[].PrivateIpAddress ${NAME}.json > ${NAME}.ip

    echo "Successfully created ${NAME} look in ${NAME}.json ${NAME}.ip"
}

function cmd_aws_start_vm
{
    ID=$(cmd_aws_to_vm_id $1)
    aws ec2 start-instances --instance-id "$ID"
}

function cmd_aws_stop_vm
{
    ID=$(cmd_aws_to_vm_id $1)
    aws ec2 stop-instances --instance-id "$ID"
}

function cmd_aws_destroy_vm
{
    # Supply a vm id or a name.
    NAMEID="$1"
    YESREALLY=false
    if [ "$NAMEID" = "--yes-really-destroy-now" ]
    then
        NAMEID="$2"
        YESREALLY=true
    fi
    ID=$(cmd_aws_to_vm_id "$NAMEID")

    CMD="aws ec2 terminate-instances --instance-ids $ID"

    echo "Deleting vm ----------------"
    cmd_aws_show_vm $ID
    echo "----------------------------"

    if [ "$YESREALLY" = "false" ]
    then
        echo
        echo "Type \"delete $ID\" to delete vm."
        read d n
        if [ "$d" != "delete" ] || [ "$n" != "$ID" ]
        then
            echo "Nothing deleted."
            exit 1
        fi
    fi

    eval "$CMD"
}

function summarize_aws_vm
{
    # Expects a compact json on a single line, no extra spaces.
    JSON="$1"
    if [ "$verbose" = "true" ]; then echo "$JSON"; fi
    NAME=$(getTag Name "$JSON")
    ID=$(echo "$JSON" | jq -jr '.InstanceId')
    STATUS=$(echo "$JSON" | jq -jr '.State.Name')
    TIMESTAMP=$(echo "$JSON" | jq -jr .LaunchTime)
    SINCE=$(duration_since "$TIMESTAMP")
    LOCATION=$(echo "$JSON" | jq -r '.Placement.AvailabilityZone')
    IP=$(echo "$JSON" | jq -r '.PublicIpAddress')
    PIP=$(echo "$JSON" | jq -r '.PrivateIpAddress')
    TYPE=$(echo "$JSON" | jq -r '.InstanceType')

    if [ "$IP" = "null" ]; then IP="" ; fi

    printf "aws\t$NAME\t$STATUS\t$SINCE\t$LOCATION\t$TYPE\t$ID\t$PIP\t$IP\n"
}

function cmd_aws_show_vm {
    ID=$(cmd_aws_to_vm_id $1)

    aws ec2 describe-instances --instance-id=$ID | jq -c '.Reservations[].Instances[]' | while IFS=$"\n" read -r info; do summarize_aws_vm "$info" ; done
}

CMD_AWS_LIST_VMS="aws ec2 describe-instances"
function cmd_aws_list_vms {
    $CMD_AWS_LIST_VMS | jq -c '.Reservations[].Instances[]' | while IFS=$"\n" read -r info; do summarize_aws_vm "$info" ; done
}

function cmd_aws_ssh_to_vm
{
    SERVER=$1
    IP=$(aws ec2 describe-instances | jq -c '.Reservations[].Instances[]'  | jq -r '.PublicIpAddress')
    ssh -i ~/Nycklar/StockholmServersKeyPair.pem ubuntu@$IP
}

function cmd_aws_set_vm_customer
{
    SERVER="$1"
    CUSTOMER="$2"
    aws ec2 create-tags --resources $SERVER --tags 'Key=Customer,Value='$CUSTOMER
}
