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

    git checkout master >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge" "$(cat test4commitmsg)"

    git checkout -b "id/42" >/dev/null 2>&1
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 42" "$(cat test4commitmsg)"

    git checkout -b "bug/id/41" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 41" "$(cat test4commitmsg)"

    git checkout -b "id/40"  >/dev/null 2>&1
    echo "hoge refs 40" > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 40" "$(cat test4commitmsg)"


    git checkout -b "id/10/aaa" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 10" "$(cat test4commitmsg)"

    git checkout -b "a/id/0/b" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 0" "$(cat test4commitmsg)"

    git checkout master >/dev/null 2>&1
    git branch -D "id/42" >/dev/null 2>&1
    git branch -D "bug/id/41" >/dev/null 2>&1
    git branch -D "id/40" >/dev/null 2>&1
    git branch -D "id/10/aaa" >/dev/null 2>&1
    git branch -D "a/id/0/b" >/dev/null 2>&1
    rm test4commitmsg

    teardown
}

. ./shunit2/src/shell/shunit2
