#############################################################
# Moln main function entry ##################################
#############################################################

# Extract all commands from the above set of command categories by parsing this file.
all_cmds="$(eval echo $(grep -a ^cmds_ "$MOLN" | sed 's/\([^=]*\)=.*/\$\1/'))"

# Extract all command groups.
all_cmd_groups="$(grep -a ^cmds_ "$MOLN" | sed 's/\([^=]*\)=.*/\$\1/')"

# Now check the cloud selected, or all of them.
all_clouds="all aws azure gcloud"
clouds="aws azure gcloud"
verbose=false
list_help=false

if [ -t 1 ]
then
    output=terminal
else
    output=ascii
fi

if ! command -v xmq &> /dev/null
then
    echo "You need to install xmq before using moln. https://libxmq.org"
    exit 1
fi

LAST_ARG="${@: -1}"
OUTPUT_TRANSFORM="transform $TMP_DIR/transforms/textify.xslq to-text"
OUTPUT_CMD="true"

if [ "$LAST_ARG" = "browse" ] || [ "$LAST_ARG" = "br" ]
then
    OUTPUT_TRANSFORM="to-html > /tmp/moln_browse.html"
    OUTPUT_CMD="firefox /tmp/moln_browse.html"
fi

while :
do
    if [[ ! "$1" =~ -[a-z_-]+ ]]
    then
        break
    fi

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

    if [[ "$1" =~ --output=[a-z]+ ]]
    then
        output=$(echo "$1" | cut -f 2 -d '=')
        case $output in
            terminal | ascii | man | htmq | tex)
                true ;;
            *)
                echo "Not a valid output format: $output"
                echo "Use one of terminal ascii man htmq tex"
                exit 1
        esac
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
                            info="$info $pre_cloud$cloud$post_cloud"
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
        list_help=true
        shift 1
    fi
done

case $output in
    terminal)
        pre_group="$blue"
        post_group="$normal
"
        pre_cmd="$red"
        post_cmd="$normal "
        pre_help=""
        post_help="
"
        pre_cloud="$green"
        post_cloud="$normal
"
        ;;
    ascii)
        pre_group=""
        post_group="
"
        pre_cmd=""
        post_cmd=" "
        pre_help=""
        post_help="
"
        pre_cloud=""
        post_cloud="
"
        ;;
    man)
        pre_group=".SH "
        post_group="
"
        pre_cmd="\\fB"
        post_cmd="\\fR"
        pre_help=" "
        post_help="
.br"
        pre_cloud='
·'
        post_cloud="
.br
"
        ;;
    htmq)
        pre_group="h2='"
        post_group="' ""
"
        pre_cmd="cmd='"
        post_cmd="' "
        pre_help="help=' "
        post_help="' br
"
        pre_cloud="pre(class=cloud)='"
        post_cloud="'
"
        ;;
    tex)
        pre_group="{\\large "
        post_group="}\\par
"
        pre_cmd="\\cmd{"
        post_cmd="} "
        pre_help="\\help{"
        post_help="}
"
        pre_cloud="\\cloud{"
        post_cloud="}
"
        ;;
esac


if [ "$list_help" = true ]
then
    for group in $all_cmd_groups
    do
        echo -n "${pre_group}${group#*_}${post_group}"
        tmp="$(eval echo $group)"
        for cmd in $tmp
        do
            helpfunc="help_$(echo "$cmd" | sed 's/-/_/g')"
            cmdfuncmatch="cmd_.*_$(echo "$cmd" | sed 's/-/_/g')"
            if [ "$(type -t $helpfunc)" = "function" ]
            then
                # This picks the first cloud implementation and extracts the arguments from there.
                arguments="$(sed -n '/'$cmdfuncmatch'/,/^\}$/{p;/^\}/q}' moln  | grep '="\$[1-9]"' | tr -d ' ' | cut -f 1 -d '=' | tr '\n' ' ')"
                arguments=$(echo $arguments | sed 's/^[ \t]*//;s/[ \t]*$//')
                if [ -n "$arguments" ]
                then
                    arguments=" $arguments"
                fi
                help=$(eval $helpfunc | head -n 1)
                echo -n "${pre_cmd}$cmd$arguments${post_cmd}${pre_help}${help}${post_help}"
                for cloud in aws azure gcloud
                do
                    cmdvar="cmd_${cloud}_$(echo "$cmd" | sed 's/-/_/g')"
                    cmdvar=$(echo $cmdvar | tr 'a-z' 'A-Z')
                    body=$(eval echo "\$$cmdvar")
                    if [ -n "$body" ]
                    then
                        echo -n "$pre_cloud"
                        if [ "$output" = "terminal" ] || [ "$output" = "ascii" ]
                        then
                            tabs 8
                            echo -n "$body" | fold -s -w 80  | sed -e "s|^|\t|g"
                            tabs -8
                        else
                            echo -n "$body"
                        fi
                        echo -n "$post_cloud"
                    fi
                done
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
    echo "Usage: moln [options] {all|aws|azure|gcloud} [command] <args>"
    echo "       -l  --list-commands List all commands"
    echo "       -lc --list-clouds   List all clouds"
    echo "       --list-help         List help"
    echo "       --output=[terminal|ascii|man|htmq|tex]"
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
