alias	lynx	lynx -cfg=${HOME}/software/lynx2-8-2/lynx.cfg
alias	olympia	setenv DISPLAY olympia:0
unalias	more

if ($?SETPATHS) then
    if (-d /asi) then
        if (-d /asi/net/common/user-defaults/bin) then
            setenv PATH ${PATH}:/asi/net/common/user-defaults/bin
        endif

        if (-d /asi/local/bin) then
            setenv PATH ${PATH}:/asi/local/bin
        endif

        if (-d /asi/local/man) then
            setenv MANPATH ${MANPATH}:/asi/local/man
        endif
    endif

    if (-d /usr/X11R6/bin) then
        setenv PATH ${PATH}:/usr/X11R6/bin
    endif

    if (-d /usr/local/sde4/bin) then
        setenv PATH ${PATH}:/usr/local/sde4/bin
    endif
endif

if ($?TERM) then
    if ($?tcsh) then
        if ($TERM == xterm) then
            set prompt='%{\e]0\;[%n %m] \!:%c03>^g%}[%n %m] \!:%B%c03%b%# '
        else
            set prompt='[%n %m] \!:%B%c03%b%# '
        endif
    else
        set prompt='[\!] '
    endif
endif

setenv	CVSROOT	/asi/db/cvsroot
setenv	CVSREAD	1

set ellipsis
stty erase '^?'
setenv PYTHONPATH /asi/local/bin
