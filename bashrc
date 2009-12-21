#!/bin/bash

if [ ! -z "${HOME}" ]; then
    PYENV_HOME="${HOME}/software/pyenv"

    function module() {
        module_file=`${PYENV_HOME}/modulecmd -s bash "$@"`
        if [ -f "${module_file}" ]; then
            . "${module_file}"
            rm -f "${module_file}"
        fi
        unset module_file
    }
fi

if [ ! -z "${PS1}" ]; then
    interactive=yes
else
    interactive=no
fi

if [ ! -z "`which uname`" ]; then
    export MACHNAME=`uname -m`
    export OSTYPE=`uname -s`
else
    export MACHNAME=unknown
    export OSTYPE=unknown
fi

# Figure out the current host name
if [ -r "${HOME}/.host" ]; then
    export HOST="`cat ${HOME}/.host`"
elif [ ! -z "`which hostname`" ]; then
    export HOST="`hostname`"
elif [ ! -z "`which uname`" ]; then
    export HOST="`uname -n`"
else
    export HOST=unknown
fi
export HOST="`echo ${HOST} | tr '[:upper:]' '[:lower:]'`"

# Figure out the current domain name
if [ -r "${HOME}/.domainname" ]; then
    export DOMAINNAME="`cat ${HOME}/.domainname`"
elif [ ! -z "`which domainname`" ]; then
    export DOMAINNAME="`domainname`"
else
    export DOMAINNAME=unknown
fi
export DOMAINNAME="`echo ${DOMAINNAME} | tr '[:upper:]' '[:lower:]'`"

if [ -z "${SHLVL}" ] || [ "${SHLVL}" -eq 1 ]; then
    t_setpaths=yes
elif [ "${TERM}" == "screen" ] || [ "${TERM}" == "screen-w" ]; then
    t_setpaths=yes
fi

if [ "${t_setpaths}" == "yes" ]; then
    module load org.merly.init.paths
fi

# all interactive stuff....
if [ "${interactive}" == "yes" ]; then
    if [ ! -z "`type -t tput`" ]; then
        bold_cmd="\[`tput bold`\]"
        unbold_cmd="\[`tput rmso`\]"
    fi

    if [ $UID -eq 0 ]; then
        prompt_end='%'
    else
        prompt_end='>'
    fi

    PS1="\[\e]0;[\h]:\w${prompt_end}\a\][\h]:${bold_cmd}\w${unbold_cmd}${prompt_end} "

    # merging history
    export PROMPT_COMMAND='history -a; history -n'
    shopt -s histappend

    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'

    alias l='ls -F'
    alias ls='ls -F'
    alias ll='ls -l'
    alias lla='ls -al'

    alias more='less -meiR'

    # editors
    alias en='emacs -nw'
    alias em='emacs'
fi
