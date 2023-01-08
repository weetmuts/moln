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
