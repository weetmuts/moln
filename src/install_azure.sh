function cmd_azure_install
{
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
