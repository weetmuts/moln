cmds_DNS="list-hosted-zones list-dns-records upsert-dns-record remove-dns-record list-domains"

function help_list_hosted_zones
{
    echo "List zones the dns is configured to serve."
}

function help_list_dns_records
{
    echo "List dns records in a zone."
}

function help_list_domains
{
    echo "List dns domains."
}

function cmd_list_hosted_zones_pre
{
    printf "CLOUD\tDOMAIN\tPRIVATE\tID\t\n"
}

function cmd_aws_list_hosted_zones
{
    aws route53 --region us-east-1 list-hosted-zones | \
        jq -r '.HostedZones[] | [ "aws", .Name, .Config.PrivateZone, .Id ] | join("\t")'
}

function cmd_list_dns_records_pre
{
    printf "CLOUD\tDOMAIN\tTYPE\tTTL\tIP\t\n"
}

function cmd_aws_list_dns_records
{
    DOMAIN=$1

    ID=$(aws route53 list-hosted-zones-by-name --dns-name ${DOMAIN} --query HostedZones[].Id --output text | cut -d/ -f3)

    aws route53 list-resource-record-sets --hosted-zone-id=${ID} | \
        jq -r '.ResourceRecordSets[] | [ "aws", .Name, .Type, .TTL, (.ResourceRecords[].Value )  ] | join("\t")' \
        | grep -v "SOA" | grep -v "NS"
}

function cmd_list_domains_pre
{
    printf "CLOUD\tDOMAIN\tAUTO_RENEW\tTRANSFER_LOCK\tEXPIRES\t\n"
}

function cmd_aws_list_domains
{
    aws route53domains --region us-east-1 list-domains | \
        jq -r '.Domains[] | [ "aws", .DomainName, .AutoRenew, .TransferLock, .Expiry ] | join("\t")'
}

function cmd_aws_upsert_dns_record
{
    # Usage: moln aws upsert-dns-record testur.ferrrbarr.com A 10.11.12.13
    NAME=$1
    TYPE=$2
    DEST=$3

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

    aws route53 change-resource-record-sets --hosted-zone-id ${ID} --change-batch file://${FILE}
}

function cmd_aws_remove_dns_record
{
    # Usage: moln aws remove-dns-record testur.ferrrbarr.com
    NAME=$1

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

    aws route53 change-resource-record-sets --hosted-zone-id ${ID} --change-batch file://${FILE}
}
