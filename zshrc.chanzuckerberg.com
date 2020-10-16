function syncmaster() {
    hg-pullmaster.sh && \
        (([ $(hg boo -q | egrep '^t(ony)?tung' | wc -l) -ne 0 ] && hg push $(hg boo -q | egrep '^t(ony)?tung' | awk '/^/{print "-B"}1') -f) || true) && \
        hg sl
}

function load_conda() {
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/Users/ttung/software/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/Users/ttung/software/miniconda3/etc/profile.d/conda.sh" ]; then
            . "/Users/ttung/software/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="/Users/ttung/software/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
}

module load com.chanzuckerberg.aws-oidc
