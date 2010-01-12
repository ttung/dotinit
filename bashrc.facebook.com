#!/bin/bash

if [ "${t_setpaths}" == "yes" ]; then
    module loaded | grep -q com.facebook.init.paths
    if [ $? -eq 0 ]; then
        module unload com.facebook.init.paths
    fi
    module load com.facebook.init.paths
fi

if [ "${interactive}" == "yes" ] &&
    [ ${BASH_VERSINFO[0]} -eq 3 ] &&
    [ -x "${HOME}/software/${MACHTYPE}-${OSTYPE}/bash-4.0/bin/bash" ]; then
    ${HOME}/software/${MACHTYPE}-${OSTYPE}/bash-4.0/bin/bash
    exit
fi

alias reset_err="sudo tcsh -c 'cat /dev/null >! ~ttung/logs/error_log_ttung'"
