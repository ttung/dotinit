unalias postcmd
set cp_version=0.12.26

if (! $?PATH) then
    set path = (/bin /usr/bin)
endif

#interactive shell?
set echo_style=both
if ($?prompt) then
    #alias cstat 'echo -n \!*'
    alias cstat 'echo \!* > /dev/null'
    set f_interactive
    unset prompt                # we'll set it later anyway...
    limit coredumpsize 15360k
else
    alias cstat 'echo \!* > /dev/null'
    limit coredumpsize 0
    set prompt=${HOST}':\!> '
endif

if ($?f_interactive) then
    cstat "cshrc package ${cp_version}\n\n"
    cstat "Initializing...\n"
    cstat "  main..."

    if ($?TERM) then
        if ($TERM == screen || $TERM == screen-w) then
            setenv TERMTYPE screen
        else if ($TERM == xterm-color) then
            setenv TERMTYPE xterm
        else
            setenv TERMTYPE $TERM
        endif
    else
        setenv TERMTYPE dumb
    endif
endif

if ( (-x /bin/uname) || (-x /usr/bin/uname) ) then
    setenv MACHTYPE `uname -p`
else
    setenv MACHTYPE UNKNOWN
endif

if ( (-x /bin/uname) || (-x /usr/bin/uname) ) then
    setenv OSTYPE `uname -s`
else
    setenv OSTYPE UNKNOWN
endif

# Figure out the current host name and YP domain 
if (-r $HOME/.host) then
    setenv HOST `cat $HOME/.host`
endif
if (! $?HOST) then
    if ( (-x /usr/bin/hostname) || (-x /bin/hostname) ) then
        setenv HOST `hostname`
    else
        setenv HOST `uname -n`
    endif
endif
setenv HOST `echo ${HOST} | tr '[:upper:]' '[:lower:]'`
cstat "."

if (! $?MACHNAME) then
    if ( (-x /bin/sed) || (-x /usr/bin/sed) ) then
        setenv MACHNAME `echo $HOST | sed 's/\..*//'`
    endif
endif
setenv PROMPT_MACHNAME $MACHNAME
cstat "."

if (-r $HOME/.domainname) then
    setenv YPDOMAIN `cat $HOME/.domainname`
    if ("$YPDOMAIN" == "") unsetenv YPDOMAIN
endif
if (! $?YPDOMAIN) then
    if (! $?YPDOMAIN && -x /bin/domainname) then
        setenv YPDOMAIN `domainname`
        if ("$YPDOMAIN" == "") unsetenv YPDOMAIN
    endif
    if (! $?YPDOMAIN && -r /etc/ypdomainname) then
        setenv YPDOMAIN `cat /etc/ypdomainname`
        if ("$YPDOMAIN" == "") unsetenv YPDOMAIN
    endif
    if (! $?YPDOMAIN) then
        setenv YPDOMAIN $HOST
    endif
endif
setenv YPDOMAIN `echo ${YPDOMAIN} | tr '[:upper:]' '[:lower:]'`
cstat "."
cstat "done\n"

if (! $?SHLVL) then
    set f_gatherpaths f_setpaths
else
    if ($SHLVL == 1) then
        set f_gatherpaths f_setpaths
    else if ($?TERMTYPE && $?f_interactive) then
        if ($TERMTYPE == "screen") then
            set f_gatherpaths f_setpaths
        endif
    endif
endif

if ($?f_gatherpaths) then
    if ($?HOME) then
        if (-r $HOME/.cshrc.paths) then
            cstat "  gather-paths..."
	    source $HOME/.cshrc.paths
        endif
    endif

    # do host dependent initialization, but silently.  we're just gathering paths.
    if ($?YPDOMAIN) then
        if ("$YPDOMAIN" != "$HOST" && -r $HOME/.cshrc.$YPDOMAIN) then
            source $HOME/.cshrc.$YPDOMAIN
        endif
    endif
    if (-r $HOME/.cshrc.$HOST) then
        source $HOME/.cshrc.$HOST
    endif
endif

if ($?f_setpaths) then
    unset f_gatherpaths           # go into the setting mode
    if ($?HOME) then
        if (-r $HOME/.cshrc.paths) then
            cstat "  set-paths..."
	    source $HOME/.cshrc.paths
            set f_pathsset
        endif
    endif

    if (! $?f_pathsset) then
        cstat ""
        if ($?HOME) then
            cstat "WARNING: ${HOME}/.cshrc.paths not available, using default:"
        else
            cstat "WARNING: .cshrc.paths not available, using default:"
        endif
        set path = (${HOME}/bin /bin /usr/bin /usr/local/bin)
        cstat "	" $path
    endif
    unset f_setpaths f_pathsset
endif

if ($?HOME) then
    if (-r $HOME/.cshrc.aliases) then
        cstat "  aliases..."
        source $HOME/.cshrc.aliases
    else
        cstat ""
        cstat "WARNING: $HOME/.cshrc.aliases unavailable"
    endif
endif

if ($?HOME && $?tcsh) then
    if (-r $HOME/.cshrc.complete) then
        cstat "  complete..."
        source $HOME/.cshrc.complete
    else
        cstat ""
        cstat "WARNING: $HOME/.cshrc.complete unavailable"
    endif
endif

# do host dependent initialization
if ($?YPDOMAIN) then
    if ("$YPDOMAIN" != "$HOST" && -r $HOME/.cshrc.$YPDOMAIN) then
        cstat "  domain-based..."
        source $HOME/.cshrc.$YPDOMAIN
    endif
endif
if (-r $HOME/.cshrc.$HOST) then
    cstat "  host-based..."
    source $HOME/.cshrc.$HOST
endif

cstat "\n"

if ($?f_interactive) then
    cstat "Starting interactive login\n\n"
    if (-r $HOME/.cshrc.interactive) then
	source $HOME/.cshrc.interactive
    else
        cstat ""
	cstat "WARNING: cannot find $HOME/.cshrc.interactive"
    endif
endif

if ($?f_interactive) then
    setenv F_INTERACTIVE_PARENT
    unset f_interactive
    unalias cstat
else
    exit
endif

#this must be at the bottom!
if (! $?TERMTYPE) exit

if ($?f_dontshowproc) then
    unset f_dontshowproc
    if ( ($?prompt) && ($TERMTYPE == xterm || $TERMTYPE == screen) ) alias postcmd 'history -S'
    exit
endif

if ( ($?prompt) && ($TERMTYPE == xterm || $TERMTYPE == screen) ) alias postcmd 'history -S; echo -n "\e]0;['${PROMPT_MACHNAME}${WINDOW_NUM:q}']:`pwd`> \!-0:q\a"'
