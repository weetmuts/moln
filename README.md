# Moln

A bash shell script to simplify work with multiple cloud providers. In
particular when you can't remember the cli command for your cloud
flavour of the day.

Do for example `moln aws list-vms` to list your vms in a plain list.
To also learn the aws cli command for this do: `moln --verbose aws list-vms`

This script focuses on simple use cases. For more advanced use cases
please learn from the script and/or copy the script content to your
own code.  You only need to keep the license and attribution to me if
you copy large parts of this script.

Do `configure && make && sudo make install` to install it in
/usr/local/bin and /etc/bash_completion.d.

First lets install the aws cli (and likewise for azure and gcloud).
```
moln aws install
```

Make sure you have configured your credentials:
```
cat ~/.aws/credentials
[default]
aws_access_key_id = xxxxxxxxxxxxxxxxxxxx
aws_secret_access_key = yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
```

Now list for example the vpcs:
```
moln aws list-vps
```

Moln has tab completion so just type `moln aws` and press tab and
you will see all commands. Type `moln aws list-` and press tab to see
all list commands for example `moln aws list-roles`

Now you can assume the role in your shell:
```shell
moln aws assume-role my_working_role TIME_TO_WORK

aws sts assume-role --role-arn arn:aws:iam::123456789012:role/my_working_role --role-session-name TIME_TO_WORK > session.token
Role session my_working_role/TIME_TO_WORK expires 2022-10-21T16:37:56+00:00

me@mycompyter:~/$ [my_working_role/TIME_TO_WORK]$
```