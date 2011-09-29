#! /bin/sh

saveconfig()
{
    local key="$1"
    local conffile="$key.tmp"

    git config --local "$key" > "$conffile"
}

restoreconfig()
{
    local key="$1"
    local conffile=$key.tmp

    if [ -s $conffile ]; then
        echo "git config  --local '$key' '$(cat $conffile)'" | sh
    else
        git config --local --unset "$key"
    fi
    rm $conffile
}

setup()
{
    git commit -a -m "tmp commit for test_commit-msg.sh. PID $$" >/dev/null 2>&1

    saveconfig hook.topicBranchFormat
    saveconfig hook.msg4TopicBranch
}

teardown()
{
    restoreconfig hook.msg4TopicBranch
    restoreconfig hook.topicBranchFormat

    git log -1 --pretty=format:"%s" | grep "tmp commit for test_commit-msg.sh. PID $$" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        git reset HEAD^ >/dev/null 2>&1
    fi
}

test_commitmsg()
{
    setup

    local originBranch="$(git symbolic-ref HEAD | sed -e 's!^refs/heads/!!')"

    git checkout -b "normal_branch" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge" "$(cat test4commitmsg)"

    git checkout -b "id/14" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs #14" "$(cat test4commitmsg)"

    git config --local hook.topicBranchFormat "issue-%ID%"
    git checkout -b "issue-15" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs #15" "$(cat test4commitmsg)"

    git config --local hook.topicBranchFormat "issue-%ID%/[a-z]*"
    git checkout -b "issue-16/tmp" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs #16" "$(cat test4commitmsg)"

    git config --local --unset hook.topicBranchFormat
    git config --local hook.msg4TopicBranch "#%ID%"

    git checkout "id/14" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge #14" "$(cat test4commitmsg)"

    echo -e "hoge\nfoo" > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "$(echo -e 'hoge #14\nfoo')" "$(cat test4commitmsg)"

    git checkout "$originBranch" >/dev/null 2>&1
    git branch -D "normal_branch" >/dev/null 2>&1
    git branch -D "id/14" >/dev/null 2>&1
    git branch -D "issue-15" >/dev/null 2>&1
    git branch -D "issue-16/tmp" >/dev/null 2>&1
    rm test4commitmsg

    teardown
}

. ./shunit2/src/shell/shunit2
