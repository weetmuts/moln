# Basic information part of moln. Copyright (C) 2022 Fredrik Öhrström license spdx: MIT

cmds_Basic_Information="whoami"

## whoami ########################################################

function help_whoami {
    echo "whoami"
    echo "Display active account/identity."
}

function cmd_aws_whoami {
    echo "# AWS"
    aws sts get-caller-identity
}

function cmd_azure_whoami {
    echo "# Azure"
    az account list
}

function cmd_gcloud_whoami {
    echo "# Gcloud"
    gcloud config list
}
