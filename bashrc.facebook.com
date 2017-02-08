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

function running_proc_watch() {
    tmux set-option automatic-rename off
    while true; do
        output=$(date;
                 echo "";
                 ps auxf | awk '{if($8 ~ /^[DR]/) print $0;}')
        echo "${output}"
        sleep 1
        clear
    done
}

alias reset_err="sudo tcsh -c 'cat /dev/null >! ~ttung/logs/error_log_ttung'"

export LD_LIBRARY_PATH=
export HPHP_HOME=${HOME}/work/hphp
export HPHP_LIB=${HPHP_HOME}/bin
