# Copyright (C) 2022-2023 Fredrik Öhrström license spdx: MIT

cmds_VM="\
 create-vm-from-template\
 destroy-vm\
 list-vm-templates\
 list-vms\
 show-vm-image\
 show-vm\
 ssh_to_vm\
 start-vm\
 stop-vm\
"

function help_create_vm_from_template
{
    echo "Create a virtual machine based on an existing vm template."
}

function help_destroy_vm
{
    echo "Destroy a virtual machine."
}

function cmd_list_vm_templates
{
    echo "List templates that can be used to create new virtual machines."
}

function cmd_list_vm_images
{
    echo "List virtual machine images."
}

function cmd_list_vm_images_pre
{
    printf "CLOUD\tID\tCREATION\tNAME\tDESCRIPTION\tDEPRECATION\t\n"
}

function cmd_list_vms
{
    echo "List virtual machines."
}

function cmd_list_vms_pre {
    printf "CLOUD\tNAME\tSTATE\tSINCE\tLOCATION\tTYPE\tID\tIP\t\n";
}
