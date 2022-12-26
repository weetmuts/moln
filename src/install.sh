###############################################################################
# Install part of moln. Copyright (C) 2022 Fredrik Öhrström license spdx: MIT #
###############################################################################

cmds_Install_Tools="install"

function cmd_install_pre {
    mkdir -p $HOME/opt
    mkdir -p $HOME/bin
    if ! command -v unzip &> /dev/null
    then
        echo "Please install the unzip command!"
        exit 1
    fi
}

function cmd_aws_install
{
    echo "Fetching https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip into $HOME/opt"
    cd $HOME/opt
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    echo "Unzipping downloaded cli zip..."
    unzip -q awscliv2.zip
    echo "Now running: ./aws/install -i $HOME/opt/aws-cli -b $HOME/bin"
    ./aws/install -i $HOME/opt/aws-cli -b $HOME/bin
    echo "You can now delete the directory ./aws"
    echo "Done."
}

function cmd_gcloud_install {
    echo "Fetching https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-407.0.0-linux-x86_64.tar.gz"
    cd $HOME/opt
    curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-407.0.0-linux-x86_64.tar.gz -o gcsdk.tgz
    echo "Untaring downloaded cli tgz..."
    tar xzf gcsdk.tgz
    echo "Now running: ./google-cloud-sdk/install.sh"
    ./google-cloud-sdk/install.sh
    echo "You can now delete ./google-cloud-sdk"
    echo "Done."
}

function cmd_azure_install {
    echo "Removing azure-cli to avoid any old versions in Ubuntu universe 20..." ;
    sudo apt remove azure-cli -y && sudo apt autoremove -y
    sudo apt-get update
    echo "Installing necessary tools to install"
    sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg
    echo "Installing microsoft gpg public key."
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor | \
        sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
    echo "Adding microsoft deb repo to apt."
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
        sudo tee /etc/apt/sources.list.d/azure-cli.list
    echo "Installing azure-cli."
    sudo apt-get update
    sudo apt-get install azure-cli
    echo "Done."
}
