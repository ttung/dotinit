umask 022

if ( $?VISUAL == 0 ) then
    setenv VISUAL emacs
endif
if ( $?NNTPSERVER == 0 ) then
    setenv NNTPSERVER usenet.cisco.com
endif

# initialize path variables for HOME subsystem
if ($?SETPATHS) then
    if (-d /asi/local/bin) then
        setenv PATH "${PATH}:/asi/local/bin"
    endif

    if (-d /router/bin) then
        setenv PATH "/router/bin:${PATH}"
    endif

    if (-d /sw/current/solaris2bin) then
        setenv PATH "${PATH}:/sw/current/solaris2bin"
    endif

    if (-d /usr/atria/bin) then
        setenv PATH "${PATH}:/usr/atria/bin"
    endif

    if (-d /usr/local/ddts/bin) then
        setenv PATH "${PATH}:/usr/local/ddts/bin"
    endif

    if (-d /usr/atria/doc/man) then
        setenv MANPATH "${MANPATH}:/usr/atria/doc/man"
    endif

    if (-d /sw/current/man) then
        setenv MANPATH "${MANPATH}:/sw/current/man"
    endif

    if (-d /usr/local/ddts/doc/man) then
        setenv MANPATH "${MANPATH}:/usr/local/ddts/doc/man"
    endif

    if (-d /usr/local/contrib/man) then
        setenv MANPATH "${MANPATH}:/usr/local/contrib/man"
    endif

    if (${OSTYPE} == "linux" && -d /usr/local/sbtools/x86-linux-rh6.0/mips64-sb1sim-2.1.1) then
        setenv SBTOOLS_BASE /usr/local/sbtools/x86-linux-rh6.0/mips64-sb1sim-2.1.1
    else if (${OSTYPE} == "solaris" && -d /vws/xnw/sbtools/sparc-solaris-5.6/mips64-sb1sim-2.3.1) then
        setenv SBTOOLS_BASE /vws/xnw/sbtools/sparc-solaris-5.6/mips64-sb1sim-2.3.1
    endif

    if ($?SBTOOLS_BASE) then
        if (-d ${SBTOOLS_BASE}/bin) then
            setenv PATH "${SBTOOLS_BASE}/bin/:${PATH}"
        endif

        if (-d ${SBTOOLS_BASE}/man) then
            setenv MANPATH "${SBTOOLS_BASE}/man/:${MANPATH}"
        endif
    endif

    if (-d /sw/packages/gcc/c2.95.3-p4/bin) then
        setenv PATH ${PATH}:/sw/packages/gcc/c2.95.3-p4/bin
    endif

    if (-d /auto/macedon_tools/asi-utils) then
        setenv PATH "${PATH}:/auto/macedon_tools/asi-utils"
    endif
endif

cstat "."

setenv CVSROOT /vws/xel/work/CVSROOT
setenv VIEWER emacsclient-ret
setenv LPDEST e2-f2-4
setenv PRINTER e2-f2-4
if ($OSTYPE == solaris) then
    setenv TERMINFO ${HOME}/.terminfo
endif

alias	quake	'finger -l quake@quake.geo.berkeley.edu'
alias	stock	'finger stocks@qotd2.cisco.com | egrep -i "^Company|^cisco|quotes" | head -3'
alias	mito	setenv DISPLAY 171.69.39.175:0

if (-x /usr/xpg4/bin/cp) alias cp '/usr/xpg4/bin/cp -i'
if (-x /usr/xpg4/bin/mv) alias mv '/usr/xpg4/bin/mv -i'
if (-x /usr/xpg4/bin/rm) alias rm '/usr/xpg4/bin/rm -i'

# clearcase aliases
alias	ct		cleartool
alias	lsv		'ct lsview | grep ${user}'
alias	ctvstat		ct lscheckout -cview -avobs
alias	ctstat		'ctvstat | grep "checkout version" | sed -e '\''s/[^\"]*\"\([^\"]*\)\".*/\1/'\'
alias	ctdiff		ct diff -pre
if ($HOST == glenlivet) then
    alias	start_task	start_task -d /vws/xel
    alias	mkview		mkview -s /vws/xel
else if ($HOST == skoda) then
    alias	start_task	start_task -d /ws/habg
    alias	mkview		mkview -s /ws/habg
endif
alias	tagit		ct mklabel -replace BUILD
alias	cc_rmview	cc_rmview -view 
alias	mksp		nice make -j8 c6s2p2_sp-sp-mz -C /vob/ios/sys/obj-4k-apollo_plus
alias	mkrp		nice make -j8 c6sup2_rp-jk9sv-mz -C /vob/ios/sys/obj-4k-draco2-mp
if ($?tcsh) then
    if (-X emacs21) then
        alias	emacs	emacs21
    endif
endif
alias	r1		telnet 172.23.56.77 2007
alias	r2		telnet 172.23.56.77 2013
alias	r1-mcpu		telnet 172.23.56.77 2006
alias	r1-icpu		telnet 172.23.56.77 2015
alias	r1-ocpu		telnet 172.23.56.77 2008
alias	r2-mcpu		telnet 172.23.56.77 2005

alias cat1	'telnet cscpm8 2008'
alias cat1-mcpu	'telnet cscpm8 2007'

alias cat2	'telnet asipm2 6005'
alias cat2-mcpu	'telnet asipm2 6004'

# killall alias
if ($?tcsh) then
    if (! -X killall && -x ${HOME}/software/bin/mkillall) then
        alias killall mkillall
    endif
endif

if ($?LESSOPEN) unsetenv LESSOPEN

if ($?tcsh) then
    complete	ct			'p/1/( describe diff lshistory lsvtree man mkelem pwv setview )/'
    complete	cleartool		'p/1/( describe diff lshistory lsvtree man mkelem pwv setview )/'
    complete	ssh			'p/1/( cryptonite-lnx ptooie needles dundee )/' 
endif

if ($?CLEARCASE_ROOT && $?INTERACTIVE) then
    if (! $?EMACS) then
        if (-e /vob/ace/Utils) then
            cd /vob/ace
        else if (-e /vob/ios/sys) then
            cd /vob/ios
        endif
    endif
    setenv PROMPT_MACHNAME "`echo $CLEARCASE_ROOT | sed -e 's/\/view\///'`"
else
    setenv PROMPT_MACHNAME $MACHNAME
endif

if ($?TERMTYPE) then
    if ($?tcsh) then
        if ($?WINDOW) then 
            setenv WINDOW_NUM ":$WINDOW"
            unsetenv WINDOW
        else
            setenv WINDOW_NUM 
        endif

        if ($TERMTYPE == xterm) then
            set prompt='%{\e]0\;['${PROMPT_MACHNAME}${WINDOW_NUM}']:%/>^g%}['${PROMPT_MACHNAME}${WINDOW_NUM}']:%B%c03%b%# '
        else if ($TERMTYPE == screen) then
            set prompt='%{\ek\e\\\e]0\;['${PROMPT_MACHNAME}${WINDOW_NUM}']:%/>^g%}['${PROMPT_MACHNAME}${WINDOW_NUM}']:%B%c03%b%# '
            alias periodic	'if (-r '${HOME}'/tmp/tonytung-DISPLAY) setenv DISPLAY `cat '${HOME}'/tmp/tonytung-DISPLAY`'
            periodic
        else
            set prompt='['${PROMPT_MACHNAME}${WINDOW_NUM}']:%B%c03%b%# '
        endif
    else
        set prompt='[\!] '
    endif
endif

if ($?TERMTYPE && $?tcsh) then
    if ($TERM == 'xterm' && -X resize && $SHLVL == 1) then
        eval `resize`
    endif
endif

set ellipsis

unset SYS
unset dotdir

setenv NOMOTD 
setenv NOFRM
setenv NOQUOTACHECK

setenv IXIA_VERSION 3.65.284

cstat "done\n"
