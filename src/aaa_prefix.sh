#!/bin/bash
#
# Copyright (C) 2022 Fredrik Öhrström (spdx: MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

MOLN=$(realpath $0)
verbose=false
debug=false

if [ -z "$AWS_ACCOUNT" ]
then
    if [ ! -f $HOME/.config/moln/moln.env ]
    then
        mkdir -p $HOME/.config/moln
        echo "AWS_ACCOUNT=$(aws sts get-caller-identity --output text --query Account)"  >> $HOME/.config/moln/moln.env
        echo "AWS_DEFAULT_REGION=$(aws configure get region)" >> $HOME/.config/moln/moln.env
    fi
    . $HOME/.config/moln/moln.env
fi

##############################################################
normal=$(printf '\033[0m')
yellow=$(printf '\033[33m')
blue=$(printf '\033[34m')
red=$(printf '\033[31m')
green=$(printf '\033[32m')

NA="${red}NA${normal}"

function cmd_columnize_post
{
    # Default post function when a pre function has been specified.
    column -t -s $'\t'
}

function getTag
{
    local NAME="$1"
    local JSON="$2"
    local HASTAGS=$(echo "$JSON" | jq -jr '.Tags')
    if [ "$HASTAGS" = "null" ]
    then
        # Tags does not exist at all.
        echo "$NA"
    else
        local VAL=$(echo "$JSON" | jq -jr '(.Tags[] | select (.Key == "'$NAME'") | .Value)')
        if [ -n "$VAL" ]
        then
            echo "$VAL"
        else
            echo "$NA"
        fi
    fi
}

function duration_since
{
    # Take a timestamp as an argument and output: 4m (for 4minutes) 4h (for 4 hours) 8d (for 8 days)
    TIMESTAMP="$1"
    THEN=$(date -d "$TIMESTAMP" "+%s")
    NOW=$(date "+%s")
    let DIFF=($NOW-$THEN)/86400
    if [ "$DIFF" = "0" ]
    then
        let DIFF=($NOW-$THEN)/3600
        if [ "$DIFF" = "0" ]
        then
            let DIFF=($NOW-$THEN)/60
            echo "${DIFF}m"
        else
            echo "${DIFF}h"
        fi
    else
        echo "${DIFF}d"
    fi
}
