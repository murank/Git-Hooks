# Git Hooks

## What's this

Git hooks that assist TiDD(Ticket-Driven Development) with Git.

## Contents

### Hook scripts

* __pre-commit__ (for normal repository):  
Just deny commit on master branch.

* __commit-msg__ (for normal repository):  
Extract ticket ID from the name of the current branch,
and insert it to the first line of a commit message.
The formats of a branch name and a message to be inserted are configurable.

* __prepare-commit-msg__ (for normal repository):  
Show diff of the current commit when editing its commit message.

 NB: the messages of the commits with -c or -C options won't include the diff,
since we cannot distinguish the options
(one can ignore the additional information but the other cannot).

* __common.sh__ (for normal repository):  
Common functions for pre-commit and commit-msg.

* __update__ (for bare repository):  
Deny push with commits that don't have a ticket ID in their commit messages.

### Installation script

* __git-hooks__:  
Help to install above hook scripts in repositories, and to update git-hooks itself.

## Instalation
1. Download [git-hooks](https://github.com/murank/Git-Hooks/raw/master/git-hooks) and
   place it in the same directory as other git commands:
   * /usr/bin
   * /usr/local/bin
   * or you may get the suitable direcotry by \`__which git__\`

2. Run \`__git hooks install https://github.com/murank/Git-Hooks/raw/master__\`
   in a repository (NB: it requires _curl_).  

If you get SSL certificate problem of curl, set 'http.sslVerify' to 'false'
(\`__git config --global http.sslVerify false__\`) or [install CA certificates](http://stackoverflow.com/questions/3777075/https-github-access).


If you want to use bash-completion of git-hooks, install git-completion and
place [git-hooks-completion.bash](https://github.com/murank/Git-Hooks/raw/master/git-hooks-completion.bash)
in a 'bash-completion.d' directory:

* /etc/bash-completion.d
* /usr/local/etc/bash-completion.d
* ~/bash-completion.d


To update git-hooks, Run '__git hooks update https://github.com/murank/Git-Hooks/raw/master__'.

## Cofiguration

These scripts use some git-config:

* __hook.remoteURL__ (used by git-hooks):  
A default url that git-hooks gets hook scripts and git-hooks itself
from (git-hooks will download _script_ from ${hook.remoteURL}/_script_).

* __hook.topicBranchFormat__ (used by commit-msg):  
commit-msg will extract ticket ID from the name of topic branches within this format
(by default, it's 'id/%ID%).

    Indicate the position of ticket ID by '__%ID%__' (it will replaced '[0-9][0-9]\*').
    And you can also use regex of sed to specify the format (but you shouldn't use brackets'()').  
    __e.g.__ If hook.topicBranchFormat is '__id/%ID%/[a-z]*__', then the ticket ID of the topic
    branch 'id/12/work' is 12.

* __hook.msg4TopicBranch__ (used by commit-msg):  
A format of the message to be inserted into a commit message (by default, it's 'refs #%ID%').

    Indicate the position to insert ticket ID by '__%ID%__' (it will replaced '\\1').  
    __e.g.__ If hook.msg4TopicBranch is '__#%ID%__', then the message to be inserted
    with ticket ID 13 is '#13'.

## Usage

git hooks &lt;command&gt; [remoteURL]

Available commands are:  
__install__	Install hooks into the current git repository  
__update__	Update this script

And git-hooks will download scripts from _remoteURL_.
If you want to skip passing the parameter, set 'hook.remoteURL'.

## License

Test scripts (test_*) and files in 'shunit2' directory are distributed 
under the [LGPL(v2.1)](http://www.gnu.org/licenses/lgpl-2.1.html),
and others are under the [NYSL(0.9982)](http://www.kmonos.net/nysl/).

