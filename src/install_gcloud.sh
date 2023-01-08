function cmd_gcloud_install
{
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
