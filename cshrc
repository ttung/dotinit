unalias postcmd
set cp_version=0.12.0

if (! $?PATH) then
    set path = (/bin /usr/bin)
endif

#interactive shell?
set echo_style=both
if ($?prompt) then
    alias cstat 'echo -n \!*'
    set INTERACTIVE
    unset prompt                # we'll set it later anyway...
    limit coredumpsize 15360k
else
    alias cstat 'echo \!* > /dev/null'
    limit coredumpsize 0
endif

if ($?INTERACTIVE) then
    cstat "cshrc package ${cp_version}\n\n"
    cstat "Initializing...\n"
    cstat "  main..."

    if ($?TERM) then
        if ($TERM == screen || $TERM == screen-w) then
            set TERMTYPE = screen
        else
            set TERMTYPE = $TERM
        endif
    endif
endif

if (! $?MACHTYPE) then
    if ( (-x /bin/sed) || (-x /usr/bin/sed) ) then
        if ( (-x /bin/arch) || (-x /usr/bin/arch) ) then
            setenv MACHTYPE `arch | sed 's/\//-/'`
        else if ( (-x /bin/mach) || (-x /usr/bin/mach) ) then
            setenv MACHTYPE `mach | sed 's/\//-/'`
        else if ( (-x /bin/uname) || (-x /usr/bin/uname) ) then
            setenv MACHTYPE `uname -p | sed 's/\//-/'`
        else
            setenv MACHTYPE UNKNOWN
        endif
    else
        if ( (-x /bin/arch) || (-x /usr/bin/arch) ) then
            setenv MACHTYPE `arch`
        else if ( (-x /bin/mach) || (-x /usr/bin/mach) ) then
            setenv MACHTYPE `mach`
        else if ( (-x /bin/uname) || (-x /usr/bin/uname) ) then
            setenv MACHTYPE `uname -p`
        else
            setenv MACHTYPE UNKNOWN
        endif
    endif
endif

if (! $?OSTYPE) then
    if ( (-x /bin/uname) || (-x /usr/bin/uname) ) then
        setenv OSTYPE `uname -s`
    endif
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
    set SETPATHS
else
    if ($SHLVL == 1) then
        set SETPATHS
    else if ($?TERMTYPE && $?INTERACTIVE) then
        if ($TERMTYPE == "screen") then
            set SETPATHS
        endif
    endif
endif

if ($?SETPATHS) then
    if ($?HOME) then
        if (-r $HOME/.cshrc.paths) then
            cstat "  paths..."
	    source $HOME/.cshrc.paths
        else
            cstat ""
            cstat "WARNING: $HOME/.cshrc.paths unavailable, using default:"
            set path = ($HOME/bin /bin /usr/bin /usr/local/bin)
            cstat "   " $path
        endif
    endif
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

cstat "Starting interactive login\n\n"
if ($?INTERACTIVE) then
    if (-r $HOME/.cshrc.interactive) then
	source $HOME/.cshrc.interactive
    else
        cstat ""
	cstat "WARNING: cannot find $HOME/.cshrc.interactive"
    endif
endif

if ($?WHOAMI) unset WHOAMI
if ($?SETPATHS) unset SETPATHS
if ($?TERMTYPE) unset TERMTYPE

if ($?INTERACTIVE) then
    unset INTERACTIVE
    unalias cstat
endif

#this must be at the bottom!
if (! $?TERM) exit

if ( ($?prompt) && ($TERM == xterm || $TERM == screen || $TERM == screen-w) ) alias postcmd 'echo -n "\e]0;['${MACHNAME}${WINDOW_NUM:q}']:`pwd`> \!-0:q\a"'
