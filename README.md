# Moln

A bash shell script to handle multiple cloud providers.
Do `configure && make && sudo make install` to install it in /usr/local/bin and /etc/bash_completion.d.

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

```json
moln aws list-roles

[
    "arn:aws:iam::123456789012:role/.",
    "arn:aws:iam::123456789012:role/..",
    "arn:aws:iam::123456789012:role/...",
    "arn:aws:iam::123456789012:role/my_working_role"
]

```

Now you can assume the role in your shell:
```shell
moln aws assume-role my_working_role TIME_TO_WORK

aws sts assume-role --role-arn arn:aws:iam::123456789012:role/my_working_role --role-session-name TIME_TO_WORK > session.token
Role session my_working_role/TIME_TO_WORK expires 2022-10-21T16:37:56+00:00

me@mycompyter:~/$ [my_working_role/TIME_TO_WORK]$
```