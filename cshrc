set cp_version=0.10.4

# general initialization files
# ----------------------------
# .cshrc.aliases 1.45
# .cshrc.complete 1.4
# .cshrc.interactive 1.36
# .cshrc.login 1.1
# .cshrc.logout 1.2
# .cshrc.paths 1.14

# site-specific initialization files
# ----------------------------------
# .cshrc.crhc 1.11
# .cshrc.eng.cisco.com 1.4
# .cshrc.OCF.Berkeley.EDU 1.3
# .cshrc.soda.csua.berkeley.edu 1.21

if (! $?PATH) then
    set path = (/bin /usr/bin)
endif

#interactive shell?
if ($?prompt) then
    echo "cshrc package" $cp_version
    set INTERACTIVE
else
    limit coredumpsize 0
endif

if ($?INTERACTIVE) then
    echo -n Initializing
    echo -n "" arch
endif
if (! $?ARCH) then
    if ( (-x /bin/sed) || (-x /usr/bin/sed) ) then
        if ( (-x /bin/arch) || (-x /usr/bin/arch) ) then
            setenv ARCH `arch | sed 's/\//-/'`
        else if ( (-x /bin/mach) || (-x /usr/bin/mach) ) then
            setenv ARCH `mach | sed 's/\//-/'`
        else if ( (-x /bin/uname) || (-x /usr/bin/uname) ) then
            setenv ARCH `uname -m | sed 's/\//-/'`
        else
            setenv ARCH UNKNOWN
        endif
    else
        if ( (-x /bin/arch) || (-x /usr/bin/arch) ) then
            setenv ARCH `arch`
        else if ( (-x /bin/mach) || (-x /usr/bin/mach) ) then
            setenv ARCH `mach`
        else if ( (-x /bin/uname) || (-x /usr/bin/uname) ) then
            setenv ARCH `uname -m`
        else
            setenv ARCH UNKNOWN
        endif
    endif
endif

if (! $?OS) then
    if ( (-x /bin/uname) || (-x /usr/bin/uname) ) then
        setenv OS `uname -s`
    endif
endif

if (! $?MACHTYPE) then
    setenv MACHTYPE ${ARCH}
endif

if (! $?OSTYPE) then
    setenv OSTYPE ${OS}
endif

# Figure out the current host name and YP domain name
if ($?INTERACTIVE) then
    echo -n "" hostname
endif
if (! $?HOST) then
    if ( (-x /usr/bin/hostname) || (-x /bin/hostname) ) then
        setenv HOST `hostname`
    else
        setenv HOST `uname -n`
    endif
endif

if ($?INTERACTIVE) then
    echo -n "" machname
endif
if (! $?MACHNAME) then
    if ( (-x /bin/sed) || (-x /usr/bin/sed) ) then
        setenv MACHNAME `echo $HOST | sed 's/\..*//'`
    endif
endif

if ($?INTERACTIVE) then
    echo -n "" domain
endif
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

if ($?tcsh) then
    set watch=(1 $user any)
endif

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
            if ($?INTERACTIVE) then
                echo -n "" paths
            endif
	    source $HOME/.cshrc.paths
        else
            echo ""
            echo "WARNING: $HOME/.cshrc.paths unavailable, using default:"
            set path = ($HOME/bin /bin /usr/bin /usr/local/bin)
            echo "   " $path
        endif
    endif
endif

if ($?HOME) then
    if (-r $HOME/.cshrc.aliases) then
        if ($?INTERACTIVE) then
            echo -n "" aliases
        endif
        source $HOME/.cshrc.aliases
    else
        echo ""
        echo "WARNING: $HOME/.cshrc.aliases unavailable"
    endif
endif

if ($?HOME && $?tcsh) then
    if (-r $HOME/.cshrc.complete) then
        if ($?INTERACTIVE) then
            echo -n "" complete
        endif
        source $HOME/.cshrc.complete
    else
        echo ""
        echo "WARNING: $HOME/.cshrc.complete unavailable"
    endif
endif

if ($?INTERACTIVE) then
    echo "" interactive
    if (-r $HOME/.cshrc.interactive) then
	source $HOME/.cshrc.interactive
    else
        echo ""
	echo "WARNING: cannot find $HOME/.cshrc.interactive"
    endif
endif

# do host dependent initialization
if ($?YPDOMAIN) then
    if ("$YPDOMAIN" != "$HOST" && -r $HOME/.cshrc.$YPDOMAIN) then
        source $HOME/.cshrc.$YPDOMAIN
    endif
endif
if (-r $HOME/.cshrc.$HOST) then
    source $HOME/.cshrc.$HOST
endif

if ($?MAIL && ! $?tperiod) then
    set mail=(60 $MAIL)
endif
set echo_style=both

if ($?WHOAMI) then
    unset WHOAMI
endif

if ($?INTERACTIVE) then
    unset INTERACTIVE
endif

if ($?SETPATHS) then
    unset SETPATHS
endif

#this must be at the bottom!
if (! $?TERM) exit

if ( ($?prompt) && ($TERM == xterm) ) alias postcmd 'echo -n "\e]0;[${USER} ${MACHNAME}]:`pwd`> \!-0\a"'
