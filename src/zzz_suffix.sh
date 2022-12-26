#############################################################
# Moln main function entry ##################################
#############################################################

# Extract all commands from the above set of command categories by parsing this file.
all_cmds="$(eval echo $(grep ^cmds_ "$MOLN" | sed 's/\([^=]*\)=.*/\$\1/'))"

# Extract all command groups.
all_cmd_groups="$(grep ^cmds_ "$MOLN" | sed 's/\([^=]*\)=.*/\$\1/')"

# Now check the cloud selected, or all of them.
all_clouds="all aws azure gcloud"
clouds="aws azure gcloud"
verbose=false

if [ "$1" = "-l" ] || [ "$1" = "--list-commands" ]
then
    echo "$all_cmds"
    exit 0
fi

if [ "$1" = "-lc" ] || [ "$1" = "--list-clouds" ]
then
    echo "$all_clouds"
    exit 0
fi

if [ "$1" = "-v" ] || [ "$1" = "--verbose" ]
then
    verbose=true
    shift 1
fi

if [ "$1" = "-d" ] || [ "$1" = "--debug" ]
then
    verbose=true
    debug=true
    shift 1
fi

if [ "$1" = "--list-command-coverage" ]
then
    for i in $all_cmd_groups
    do
        echo "${blue}##### ${i#*_} ${normal}"
        echo
        {
        tmp="$(eval echo $i)"
        for j in $tmp
        do
            info=""
            for cloud in aws azure gcloud
            do
                cmdfunc="cmd_${cloud}_$(echo "$j" | sed 's/-/_/g')"
                if [ "$(type -t $cmdfunc)" = "function" ]
                then
                    info="$info $green$cloud$normal"
                fi
            done
            echo "$j $info"
        done
        } | column -t
        echo
    done
    exit 0
fi

if [ "$1" = "--list-help" ]
then
    for i in $all_cmd_groups
    do
        echo "· ${i#*_}"
        echo
        tmp="$(eval echo $i)"
        for j in $tmp
        do
            helpfunc="help_$(echo "$j" | sed 's/-/_/g')"
            if [ "$(type -t $helpfunc)" = "function" ]
            then
                echo "\fB$(eval $helpfunc | head -n 1)\fR"
                echo ".br"
                eval $helpfunc | tail -n 1
            fi
        done
        echo
    done
    exit 0
fi

cloud=$1
cmd=$2
if [ "$cloud" = "" ] || [ "$cmd" = "" ]
then
    echo "Usage: moln {all|aws|azure|gcloud} [command] <options> <args>"
    exit 0
fi

if  ! echo -n "$all_clouds" | grep -wq $cloud
then
    echo "Error: \"$cloud\" is not a valid cloud provider. ($all_clouds)"
    exit 1
fi

# Now check the command choosen.

if  ! echo -n "$all_cmds" | grep -wq $cmd
then
    echo "Error: \"$cmd\" is not a valid command."
    exit 1
fi

# Now remove the first two arguments.
shift 2

if [ "$cmd" = "assume-role" ]
then
    cmdfunc="cmd_${cloud}_$(echo "$cmd" | sed 's/-/_/g')"
    eval $cmdfunc "$*"
    exit $?
fi

prefunc="cmd_$(echo "$cmd" | sed 's/-/_/g')_pre"
postfunc="cmd_$(echo "$cmd" | sed 's/-/_/g')_post"

if [ ! "$(type -t $prefunc)" = "function" ]
then
    # This is the /bin/true function, not the boolean true.....
    prefunc=true
fi

if [ ! "$(type -t $postfunc)" = "function" ]
then
    if [ ! "$prefunc" = "true" ]
    then
        # The prefunc is set to something, but we have not explicit post.
        # Then use the default post.
        postfunc=cmd_columnize_post
    else
        # No post, and no pre, then just cat the output.
        postfunc=cat
    fi
fi

if [ "$cloud" = "all" ]
then
    (
        eval $prefunc "$*"
        for i in $clouds
        do
            cmdfunc="cmd_${i}_$(echo "$cmd" | sed 's/-/_/g')"
            if [ "$(type -t $cmdfunc)" = "function" ]
            then
                eval $cmdfunc "$*"
            else
                echo "Command $cmd is not implemented for provider $i!"  > /dev/stderr
            fi
        done
    ) | eval $postfunc "$*"
else
    (
        eval $prefunc "$*"
        cmdfunc="cmd_${cloud}_$(echo "$cmd" | sed 's/-/_/g')"
        if [ "$(type -t $cmdfunc)" = "function" ]
        then
            eval $cmdfunc "$*"
        else
            echo "Command $cmd is not implemented for provider $cloud!" > /dev/stderr
        fi
    ) | eval $postfunc
fi
