set cp_version=0.11.3

# general initialization files
# ----------------------------
# .cshrc.aliases 1.52
# .cshrc.complete 1.8
# .cshrc.interactive 1.52
# .cshrc.login 1.1
# .cshrc.logout 1.4
# .cshrc.paths 1.16

# site-specific initialization files
# ----------------------------------
# .cshrc.crhc 1.13
# .cshrc.eng.cisco.com 1.14
# .cshrc.OCF.Berkeley.EDU 1.5
# .cshrc.soda.csua.berkeley.edu 1.26

if (! $?PATH) then
    set path = (/bin /usr/bin)
endif

#interactive shell?
set echo_style=both
if ($?prompt) then
    alias pstat 'echo -n \!*'
    set INTERACTIVE
    unset prompt                # we'll set it later anyway...
else
    alias pstat 'echo \!* > /dev/null'
    limit coredumpsize 0
endif

if ($?INTERACTIVE) then
    clear

    alias pstat 'echo -n \!*'
    pstat "cshrc package ${cp_version}\n\n"
    pstat "Initializing...\n"
    pstat "  main..."
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
if (! $?HOST) then
    if ( (-x /usr/bin/hostname) || (-x /bin/hostname) ) then
        setenv HOST `hostname`
    else
        setenv HOST `uname -n`
    endif
endif
pstat "."

if (! $?MACHNAME) then
    if ( (-x /bin/sed) || (-x /usr/bin/sed) ) then
        setenv MACHNAME `echo $HOST | sed 's/\..*//'`
    endif
endif
pstat "."

if (! $?YPDOMAIN) then
    if (! $?YPDOMAIN && -r $HOME/.domainname) then
        setenv YPDOMAIN `cat $HOME/.domainname`
        if ("$YPDOMAIN" == "") unsetenv YPDOMAIN
    endif
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
pstat "."
pstat "done\n"

if (! $?SHLVL) then
    set SETPATHS
else
    if ($SHLVL == 1) then
        set SETPATHS
    endif
endif

if ($?SETPATHS) then
    if ($?HOME) then
        if (-r $HOME/.cshrc.paths) then
            pstat "  paths..."
	    source $HOME/.cshrc.paths
        else
            pstat ""
            pstat "WARNING: $HOME/.cshrc.paths unavailable, using default:"
            set path = ($HOME/bin /bin /usr/bin /usr/local/bin)
            pstat "   " $path
        endif
    endif
endif

if ($?HOME) then
    if (-r $HOME/.cshrc.aliases) then
        pstat "  aliases..."
        source $HOME/.cshrc.aliases
    else
        pstat ""
        pstat "WARNING: $HOME/.cshrc.aliases unavailable"
    endif
endif

if ($?HOME && $?tcsh) then
    if (-r $HOME/.cshrc.complete) then
        pstat "  complete..."
        source $HOME/.cshrc.complete
    else
        pstat ""
        pstat "WARNING: $HOME/.cshrc.complete unavailable"
    endif
endif

# do host dependent initialization
if ($?YPDOMAIN) then
    if ("$YPDOMAIN" != "$HOST" && -r $HOME/.cshrc.$YPDOMAIN) then
        pstat "  domain-based..."
        source $HOME/.cshrc.$YPDOMAIN
    endif
endif
if (-r $HOME/.cshrc.$HOST) then
    pstat "  host-based..."
    source $HOME/.cshrc.$HOST
endif

pstat "\n"

pstat "Starting interactive login\n\n"
if ($?INTERACTIVE) then
    if (-r $HOME/.cshrc.interactive) then
	source $HOME/.cshrc.interactive
    else
        pstat ""
	pstat "WARNING: cannot find $HOME/.cshrc.interactive"
    endif
endif

if ($?WHOAMI) then
    unset WHOAMI
endif

if ($?INTERACTIVE) then
    unset INTERACTIVE
    unalias pstat
endif

if ($?SETPATHS) then
    unset SETPATHS
endif

#this must be at the bottom!
if (! $?TERM) exit

if ( ($?prompt) && ($TERM == xterm) ) alias postcmd 'echo -n "\e]0;[${MACHNAME} ${USER}]:`pwd`> \!-0\a"'
