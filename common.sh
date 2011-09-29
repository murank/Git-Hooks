#! /bin/sh

getGitBranchName()
{
    branch="$(git symbolic-ref HEAD 2>/dev/null)" ||
            "$(git describe --contains --all HEAD)"
    echo ${branch##refs/heads/}
}

isOnMasterBranch()
{
    if [ "$(getGitBranchName)" = "master" ]; then
        return 0
    fi
    return 1
}

appendMsgTo1stLine()
{
    mv $1 $1.$$
    if [ -s "$1.$$" ]; then
    if head -1 "$1.$$" | grep "$2" > /dev/null; then
        cp "$1.$$" "$1"
    else
            sed '1s/$/ '"$2"'/' "$1.$$" > $1
    fi
    else
        echo "$2" > "$1"
    fi
    rm -f $1.$$
}

getConfigValue()
{
    local key="$1"
    local defaultValue="$2"

    git config "$key" || echo "$defaultValue"
}

replaceMarker()
{
    local replacement="$1"
    sed -e "s/%ID%/$replacement/g" | sed -e 's!/!\\/!g'
}

extractTicketId()
{
    local branchFormat="$(getConfigValue hook.topicBranchFormat 'id/%ID%' | replaceMarker '\\([0-9][0-9]*\\)')"

    getGitBranchName | grep "^$branchFormat\$" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        exit
    fi

    echo "echo '$(getGitBranchName)' | sed -e 's/$branchFormat/refs #\1/g'" | sh
}

hasTicketId()
{
    first="$(git cat-file -p $1 \
    | sed '1,/^$/d' | head -1 \
    | sed '/.*refs #[0-9][0-9]*.*/!d')"

    if [ -n "${first}" ]; then
        echo "true"
    else
        echo "false"
    fi
}

extractParents()
{
    parents="$(git cat-file -p $1 \
    | grep '^parent [0-9a-f]\{40\}$')"
    echo "${parents##parent }"
}

