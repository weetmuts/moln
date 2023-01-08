cmds_BUCKET="\
list-buckets \
list-bucket-contents \
"

function help_list_buckets
{
    echo "List storage buckets, ie aws s3/gcloud storage/azure blobs."
}

function cmd_list_buckets_pre
{
    printf "CLOUD\tNAME\t\n"
}

function help_list_bucket_content
{
    echo "List bucket contents."
}
