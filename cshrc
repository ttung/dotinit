set cp_version=0.5.18
# .cshrc.aliases 1.10
# .cshrc.crhc 1.1
# .cshrc.cso.uiuc.edu 1.1
# .cshrc.ews.uiuc.edu 1.4
# .cshrc.interactive 1.5
# .cshrc.paths 1.4
# .cshrc.soda.csua.berkeley.edu 1.7

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
#    if (! $?EMACS && ! $?0) then
if (! $?INTERACTIVE) then
#    if ( ($?prompt) && (! $?EMACS) ) then
    if ($?prompt) then
	echo "cshrc package" $cp_version
        set INTERACTIVE
    else
	limit coredumpsize 0
    endif
endif

if (! $?ARCH) then
        if (-x /bin/arch) then
                setenv ARCH `/bin/arch`
        else if (-x /usr/bin/arch) then
                setenv ARCH `/usr/bin/arch`
        else if (-x /bin/mach) then
                setenv ARCH `/bin/mach`
        else if (-x /usr/bin/mach) then
                setenv ARCH `/usr/bin/mach`
        else if (-x /bin/machine) then
                setenv ARCH `/bin/machine`
        else if (-x /usr/bin/machine) then
                setenv ARCH `/usr/bin/machine`
        else if (-x /bin/uname) then
                setenv ARCH `/bin/uname -m`
        else if (-x /usr/bin/uname) then
                setenv ARCH `/usr/bin/uname -m`
        else
                setenv ARCH UNKNOWN
        endif
endif

if (! $?OS) then
        if (-x /bin/uname) then
                setenv OS `/bin/uname -s`
        else if (-x /usr/bin/uname) then
                setenv OS `/usr/bin/uname -s`
	endif
endif

if (! $?OSTYPE) then
        setenv OSTYPE `uname -s`
endif

# Figure out the current host name and YP domain name
if (! $?HOST) then
        if (-x /usr/bin/hostname || -x /bin/hostname) then
                setenv HOST `hostname | sed 's/\..*//'`
        else
                setenv HOST `uname -n | sed 's/\..*//'`
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
