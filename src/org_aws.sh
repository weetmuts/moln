
CMD_AWS_LIST_ACCOUNTS="aws organizations list-accounts"
function cmd_aws_list_accounts {
    extract_transforms
    >&2 printf "Fetching accounts..."
    $CMD_AWS_LIST_ACCOUNTS > $TMP_DIR/list_accounts.json
    >&2 printf "\33[2K\r"
    CMD="cat $TMP_DIR/list_accounts.json | xmq transform --stringparam=current-date=$(date +%Y-%m-%d) $TMP_DIR/transforms/summarize_aws_account.xslq $OUTPUT_TRANSFORM"
    eval "$CMD"
    eval "$OUTPUT_CMD"
}
