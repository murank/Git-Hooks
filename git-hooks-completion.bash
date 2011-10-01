#!bash
#
# git-hooks-completion
# ===================
# 
# Bash completion support for [git-hooks](http://github.com/murank/Git-Hooks)
# 
# The contained completion routines provide support for completing:
# 
#  * git-hooks install and update
#
# 
# Installation
# ------------
# 
#  0. Install git-completion.
# 
#  1. Place this file in a `bash-completion.d` folder:
# 
#     * /etc/bash-completion.d
#     * /usr/local/etc/bash-completion.d
#     * ~/bash-completion.d
# 
#  2. If you are using Git < 1.7.1: Edit git-completion.sh and add the following line to the giant
#     $command case in _git:
# 
#         hooks)        _git_hooks ;;
# 
# 
# The Fine Print
# --------------
# 
# Copyright (c) 2011 [murank](http://d.hatena.ne.jp/murank)
# Copyright (c) 2010 [Justin Hileman](http://justinhileman.com)
# 
# Distributed under the [MIT License](http://creativecommons.org/licenses/MIT/)

_git_hooks ()
{
	local subcommands="install update"
	local subcommand="$(__git_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		__gitcomp "$subcommands"
		return
	fi
}

# alias __git_find_on_cmdline for backwards compatibility
if [ -z "`type -t __git_find_on_cmdline`" ]; then
	alias __git_find_on_cmdline=__git_find_subcommand
fi
