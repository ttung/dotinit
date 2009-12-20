if [ ! -z "${HOME}" ]; then
    PYENV_HOME="${HOME}/software/pyenv"

    function module() {
        module_file=`${PYENV_HOME}/modulecmd -s bash "$@"`
        if [ -f "${module_file}" ]; then
            . "${module_file}"
            rm -f "${module_file}"
        fi
    }
fi

if [ ! -z "${PS1}" ]; then
    interactive=yes
else
    interactive=no
fi

# all interactive stuff....
if [ $interactive == yes ]; then
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

    # # merging history
    # export PROMPT_COMMAND='history -a;history -n'
    # shopt -s histappend
fi
