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
    local msgFile="$1"
    local msg="$2"

    if [ ! -s "$msgFile" ]; then
        echo "$msg" > "$msgFile"
        return 0
    fi

    head -1 "$msgFile" | grep "$msg" > /dev/null
    if [ $? -eq 0 ]; then
        return 0
    fi

    sed "1s/\$/ $msg/" "$msgFile" > "$msgFile.$$"
    mv "$msgFile.$$" "$msgFile"
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
    local msgFormat="$(getConfigValue hook.msg4TopicBranch 'refs #%ID%' | replaceMarker '\\1')"

    getGitBranchName | grep "^$branchFormat\$" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        exit
    fi

    echo "echo '$(getGitBranchName)' | sed -e 's/$branchFormat/$msgFormat/g'" | sh
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

