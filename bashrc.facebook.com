#!/bin/bash

if [ "${t_setpaths}" == "yes" ]; then
    while read module
    do
        if [ "${module}" != "org.merly.init.paths" ]; then
            module unload "$module"
        fi
    done <<< "$(module loaded)"
    module load com.facebook.init.paths
fi

alias reset_err="sudo tcsh -c 'cat /dev/null >! ~ttung/logs/error_log_ttung'"

export LD_LIBRARY_PATH=
export HPHP_HOME=${HOME}/work/hphp
export HPHP_LIB=${HPHP_HOME}/bin
