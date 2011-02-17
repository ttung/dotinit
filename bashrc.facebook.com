#!/bin/bash

if [ "${t_setpaths}" == "yes" ]; then
    while read module
    do
        if [ "${module}" != "org.merly.init.paths" ]; then
            module unload "$module"
        fi
    done <<< "$(module loaded)"
    module load com.facebook.init.paths
    module load oss.emacs-22.3
fi

if [ "${interactive}" == "yes" ] &&
    [ ${BASH_VERSINFO[0]} -eq 3 ] &&
    [ -x "${HOME}/software/${MACHTYPE}-${OSTYPE}/bash-4.0/bin/bash" ]; then
    ${HOME}/software/${MACHTYPE}-${OSTYPE}/bash-4.0/bin/bash
    exit
fi

# abbrev_host="${HOST%.facebook.com}"
# if [ -d /local-${abbrev_host}/${USER}/ ]; then
#     HISTFILE=/local-${abbrev_host}/${USER}/.bash_history
# fi

alias reset_err="sudo tcsh -c 'cat /dev/null >! ~ttung/logs/error_log_ttung'"
alias gitlastrelease="/home/engshare/admin/scripts/git/git-fetch-release `svn ls svn+ssh://$(whoami)@tubbs/svnroot/tfb/releases | sed '$!d' | sed 's/\/$//'`"
