CMD_AWS_LIST_HOSTED_ZONES='aws route53 --region us-east-1 list-hosted-zones'
function cmd_aws_list_hosted_zones
{
    $CMD_AWS_LIST_HOSTED_ZONES | \
        jq -r '.HostedZones[] | [ "aws", .Name, .Config.PrivateZone, .Id ] | join("\t")'
}

CMD_AWS_LIST_DNS_RECORDS='aws route53 list-resource-record-sets --hosted-zone-id=${ID}'
function cmd_aws_list_dns_records
{
    DOMAIN=$1

    ID=$(aws route53 list-hosted-zones-by-name --dns-name ${DOMAIN} --query HostedZones[].Id --output text | cut -d/ -f3)

    eval $CMD_AWS_LIST_DNS_RECORDS | \
        jq -r '.ResourceRecordSets[] | [ "aws", .Name, .Type, .TTL, (.ResourceRecords[].Value )  ] | join("\t")' \
        | grep -v "SOA" | grep -v "NS"
}

CMD_AWS_LIST_DOMAINS='aws route53domains --region us-east-1 list-domains'
function cmd_aws_list_domains
{
    $CMD_AWS_LIST_DOMAINS | jq -r '.Domains[] | [ "aws", .DomainName, .AutoRenew, .TransferLock, .Expiry ] | join("\t")'
}

CMD_AWS_UPSERT_DNS_RECORD='aws route53 change-resource-record-sets --hosted-zone-id ${ID} --change-batch file://${FILE}'
function cmd_aws_upsert_dns_record
{
    # Usage: moln aws upsert-dns-record testur.foobar.com A 10.11.12.13
    NAME="$1"
    TYPE="$2"
    DEST="$3"

    if [ -z "$NAME" ] || [ -z "$TYPE" ] || [ -z "$DEST" ]
    then
        echo "Usage: moln aws upsert-dns-record alfa.beta.com A 1.2.3.4"
        exit 1
    fi
    # Grab the host name.
    HOST=${NAME%%.*}
    # Grab everything after the first .
    DOMAIN=${NAME#*.}

    if [ -z "$DOMAIN" ]
    then
        echo "You must have a full host.domain.com specified!"
        exit 1
    fi

    FILE=$(mktemp create_record_XXXXXXX.json)
    cat > $FILE <<EOF
{
    "Comment": "CREATE/DELETE/UPSERT a record ",
    "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
        "Name": "${NAME}.",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{ "Value": "${DEST}"}]
    }}]
}
EOF

    ID=$(aws route53 list-hosted-zones-by-name --dns-name ${DOMAIN} --query HostedZones[].Id --output text | cut -d/ -f3)

    echo "Adding $HOST $TYPE $DEST to domain $DOMAIN $ID"

    eval $CMD_AWS_UPSERT_DNS_RECORD
}

CMD_AWS_REMOVE_DNS_RECORD='aws route53 change-resource-record-sets --hosted-zone-id ${ID} --change-batch file://${FILE}'
function cmd_aws_remove_dns_record
{
    # Usage: moln aws remove-dns-record testur.ferrrbarr.com
    NAME="$1"

    if [ -z "$NAME" ]
    then
        echo "Usage: moln aws remove-dns-record alfa.beta.com"
        exit 1
    fi
    # Grab the host name.
    HOST=${NAME%%.*}
    # Grab everything after the first .
    DOMAIN=${NAME#*.}

    if [ -z "$DOMAIN" ]
    then
        echo "You must have a full host.domain.com specified!"
        exit 1
    fi

    ID=$(aws route53 list-hosted-zones-by-name --dns-name ${DOMAIN} --query HostedZones[].Id --output text | cut -d/ -f3)

    FIELDS=$(aws route53 list-resource-record-sets --hosted-zone-id ${ID} | \
                 jq -r '.ResourceRecordSets[] | [ .Name, .Type, .TTL, (.ResourceRecords[].Value )  ] | join("\t")' | \
          grep "$NAME")

    NAMEO=$(echo "$FIELDS" | cut -f 1)
    TYPE=$(echo "$FIELDS" | cut -f 2)
    TTL=$(echo "$FIELDS" | cut -f 3)
    DEST=$(echo "$FIELDS" | cut -f 4)

    if [ -z "$NAMEO" ]
    then
        echo "No record for $NAME exists!"
        exit 1
    fi

    echo "Removing $HOST $TYPE $DEST from domain $DOMAIN $ID"

    FILE=$(mktemp remove_record_XXXXXXX.json)
    cat > $FILE <<EOF
{
    "Comment": "CREATE/DELETE/UPSERT a record ",
    "Changes": [{
    "Action": "DELETE",
    "ResourceRecordSet": {
        "Name": "${NAME}",
        "Type": "${TYPE}",
        "TTL": ${TTL},
        "ResourceRecords": [{ "Value": "${DEST}"}]
    }}]
}
EOF

    eval $CMD_AWS_REMOVE_DNS_RECORD
}
