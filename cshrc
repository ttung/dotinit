set cp_version=0.6.6
# .cshrc.aliases 1.12
# .cshrc.crhc 1.3
# .cshrc.cso.uiuc.edu 1.1
# .cshrc.ews.uiuc.edu 1.4
# .cshrc.interactive 1.5
# .cshrc.paths 1.6
# .cshrc.soda.csua.berkeley.edu 1.7

set path = (/bin /usr/bin)

if (! $?WHOAMI) then
        if (-x /usr/ucb/whoami) then
                set WHOAMI = `/usr/ucb/whoami`
        else
                set WHOAMI = `whoami`
        endif
endif

if (! $?LOGNAME) then
        if ($?user) then
                setenv LOGNAME $user
        else
                setenv LOGNAME $WHOAMI
        endif
endif

setenv LOGHOME ~$LOGNAME
if (! $?HOME) then
        setenv HOME $LOGHOME
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

if (! $?YPDOMAIN) then
        if (-x /bin/domainname) then
                setenv YPDOMAIN `domainname`
                if ("$YPDOMAIN" == "") unsetenv YPDOMAIN
        endif
        if (! $?YPDOMAIN && -r /etc/ypdomainname) then
                setenv YPDOMAIN `cat /etc/ypdomainname`
                if ("$YPDOMAIN" == "") unsetenv YPDOMAIN
        endif
        if (! $?YPDOMAIN && -r $LOGHOME/.domainname) then
                setenv YPDOMAIN `cat $LOGHOME/.domainname`
                if ("$YPDOMAIN" == "") unsetenv YPDOMAIN
        endif
        if (! $?YPDOMAIN) then
                setenv YPDOMAIN $HOST
        endif
endif

if ($?tcsh) then
    set watch=(1 $user any)
endif

if ($?LOGHOME) then
    if (-r $LOGHOME/.cshrc.paths) then
	    source $LOGHOME/.cshrc.paths
    else
	    echo WARNING: $LOGHOME/.cshrc.paths unavailable, using default:
	    set path = ($LOGHOME/bin /bin /usr/bin /usr/local/bin)
	    echo "   " $path
    endif
endif

if ($?INTERACTIVE) then
    if (-r $LOGHOME/.cshrc.interactive) then
	source $LOGHOME/.cshrc.interactive
    else
	echo "WARNING: cannot find $LOGHOME/.cshrc.interactive"
    endif
endif

if ($?LOGHOME) then
    if (-r $LOGHOME/.cshrc.aliases) then
	    source $LOGHOME/.cshrc.aliases
    else
	    echo WARNING: $LOGHOME/.cshrc.aliases unavailable
    endif
endif


# do host dependent initialization
if ($?YPDOMAIN) then
        if ("$YPDOMAIN" != "$HOST" && -r $LOGHOME/.cshrc.$YPDOMAIN) then
                source $LOGHOME/.cshrc.$YPDOMAIN
        endif
endif
if (-r $LOGHOME/.cshrc.$HOST) then
        source $LOGHOME/.cshrc.$HOST
endif

if ($?MAIL) then
	set mail=(60 $MAIL)
endif

if ($?WHOAMI) then
	unset WHOAMI
endif

if ($?INTERACTIVE) then
	unset INTERACTIVE
endif
