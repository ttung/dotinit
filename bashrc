#!/bin/bash

if [ ! -z "${HOME}" ]; then
    PYENV_HOME="${HOME}/software/pyenv"

    function module() {
        local module_file=`${PYENV_HOME}/modulecmd -s bash "$@"`
        if [ -f "${module_file}" ]; then
            . "${module_file}"
            rm -f "${module_file}"
        fi
    }
fi

if [ ! -z "${PS1}" ]; then
    interactive=yes
    function init_stat() {
        # echo -en "$@"
        echo -n ""
    }
else
    interactive=no
    function init_stat() {
        echo -n ""
    }
fi

# array of functions to call before finishing up.
declare -a finalize

init_stat "main..."

if [ ! -z "`which uname`" ]; then
    export MACHTYPE=`uname -m`
    export OSTYPE=`uname -s`
else
    export MACHTYPE=unknown
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
if [ -r "${HOME}/.domain" ]; then
    export DOMAIN="`cat ${HOME}/.domain`"
elif [ ! -z "`which domainname`" ]; then
    export DOMAIN="`domainname`"
else
    export DOMAIN=unknown
fi
export DOMAIN="`echo ${DOMAIN} | tr '[:upper:]' '[:lower:]'`"

if [ -z "${SHLVL}" ] || [ "${SHLVL}" -eq 1 ]; then
    t_setpaths=yes
elif [ "${TERM}" == "screen" ] || [ "${TERM}" == "screen-w" ]; then
    t_setpaths=yes
fi
init_stat "done\n"

if [ "${t_setpaths}" == "yes" ]; then
    init_stat "paths..."
    module load --force org.merly.init.paths
    init_stat "done\n"
fi

# all aliases stuff....
if [ -r "${HOME}/.bashrc.aliases" ]; then
    . "${HOME}/.bashrc.aliases"
fi

# all completions stuff....
if [ "${interactive}" == "yes" ] &&
    [ -r "${HOME}/.bashrc.complete" ]; then
    . "${HOME}/.bashrc.complete"
fi

# all completions stuff....
if [ "${interactive}" == "yes" ] &&
    [ -r "${HOME}/.bashrc.gitcomplete" ]; then
    . "${HOME}/.bashrc.gitcomplete"
fi

# domain-specific initialization.
if [ ! -z "${DOMAIN}" ] &&
    [ "${DOMAIN}" != "${HOST}" ] &&
    [ -r "${HOME}/.bashrc.${DOMAIN}" ]; then
    . "${HOME}/.bashrc.${DOMAIN}"
fi

# host-specific initialization.
if [ ! -z "${HOST}" ] &&
    [ -r "${HOME}/.bashrc.${HOST}" ]; then
    . "${HOME}/.bashrc.${HOST}"
fi

# all interactive stuff....
if [ "${interactive}" == "yes" ] &&
    [ -r "${HOME}/.bashrc.interactive" ]; then
    . "${HOME}/.bashrc.interactive"
fi

for func in $finalize; do
    $func
done

unset t_setpaths
