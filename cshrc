set cp_version=0.8.26
# .cshrc.aliases 1.29
# .cshrc.complete 1.3
# .cshrc.crhc 1.8
# .cshrc.cso.uiuc.edu 1.1
# .cshrc.ews.uiuc.edu 1.4
# .cshrc.interactive 1.24
# .cshrc.paths 1.9
# .cshrc.soda.csua.berkeley.edu 1.13

if (! $?PATH) then
    set path = (/bin /usr/bin)
endif

#interactive shell?
if (! $?INTERACTIVE) then
    if ($?prompt) then
	echo "cshrc package" $cp_version
        set INTERACTIVE
    else
	limit coredumpsize 0
    endif
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
if (! $?HOST) then
        if ( (-x /usr/bin/hostname) || (-x /bin/hostname) ) then
                setenv HOST `hostname`
        else
                setenv HOST `uname -n`
        endif
endif

if (! $?MACHNAME) then
    if ( (-x /bin/sed) || (-x /usr/bin/sed) ) then
        setenv MACHNAME `echo $HOST | sed 's/\..*//'`
    endif
endif

if (! $?YPDOMAIN) then
        if (-x /bin/domainname) then
                setenv YPDOMAIN `domainname`
                if ("$YPDOMAIN" == "") unsetenv YPDOMAIN
        endif
        if (! $?YPDOMAIN && -r /etc/ypdomainname) then
                setenv YPDOMAIN `cat /etc/ypdomainname`
                if ("$YPDOMAIN" == "") unsetenv YPDOMAIN
        endif
        if (! $?YPDOMAIN && -r $HOME/.domainname) then
                setenv YPDOMAIN `cat $HOME/.domainname`
                if ("$YPDOMAIN" == "") unsetenv YPDOMAIN
        endif
        if (! $?YPDOMAIN) then
                setenv YPDOMAIN $HOST
        endif
endif

if ($?tcsh) then
    set watch=(1 $user any)
endif

if ($?HOME) then
    if (-r $HOME/.cshrc.paths) then
	if (! $?SHLVL) then
	    source $HOME/.cshrc.paths
	else 
	    if ($SHLVL == 1) then
		source $HOME/.cshrc.paths
	    endif
	endif
    else
	echo WARNING: $HOME/.cshrc.paths unavailable, using default:
	set path = ($HOME/bin /bin /usr/bin /usr/local/bin)
	echo "   " $path
    endif
endif

if ($?INTERACTIVE) then
    if (-r $HOME/.cshrc.interactive) then
	source $HOME/.cshrc.interactive
    else
	echo "WARNING: cannot find $HOME/.cshrc.interactive"
    endif
endif

if ($?HOME) then
    if (-r $HOME/.cshrc.aliases) then
	    source $HOME/.cshrc.aliases
    else
	    echo WARNING: $HOME/.cshrc.aliases unavailable
    endif
endif

if ($?HOME && $?tcsh) then
    if (-r $HOME/.cshrc.complete) then
	    source $HOME/.cshrc.complete
    else
	    echo WARNING: $HOME/.cshrc.complete unavailable
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

if ($?WHOAMI) then
	unset WHOAMI
endif

if ($?INTERACTIVE) then
	unset INTERACTIVE
endif

#this must be at the bottom!
if (! $?TERM) exit

if ( ($?prompt) && ($TERM == xterm) ) alias postcmd 'echo -n "\e]0;[${USER} ${MACHNAME}]:`pwd`> \!-0\a"'
