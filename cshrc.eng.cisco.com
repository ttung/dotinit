umask 022

if ( $?VISUAL == 0 ) then
    setenv VISUAL emacs
endif
if ( $?NNTPSERVER == 0 ) then
    setenv NNTPSERVER usenet.cisco.com
endif

# initialize path variables for HOME subsystem
if ($?gatherpaths) then
    set C_PATH		= (/router/bin ${C_PATH} \
                            /asi/local/bin /sw/current/solaris2bin \
                            /usr/atria/bin /usr/local/ddts/bin \
                            /sw/packages/gcc/c2.95.3-p4/bin \
                            /auto/macedon_tools/asi-utils)

    set C_MANPATH	= (${C_MANPATH} /usr/atria/doc/man /sw/current/man \
                            /usr/local/ddts/doc/man /usr/local/contrib/man)

    # temporary hack required by teambuilder
    setenv PATH         /router/bin:${PATH}
endif

cstat "."

setenv CC_DISABLE_MAKE_HINTS 1
setenv MAKEFLAG_J -j8
setenv CVSROOT /vws/xel/work/CVSROOT
setenv VIEWER emacsclient-ret
setenv LPDEST e2-f2-4
setenv PRINTER e2-f2-4
if ($OSTYPE == solaris) then
    setenv TERMINFO ${HOME}/.terminfo
endif

alias	quake	'finger -l quake@quake.geo.berkeley.edu'
alias	stock	'finger stocks@qotd2.cisco.com | egrep -i "^Company|^cisco|quotes" | head -3'

if (-x /usr/xpg4/bin/cp) alias cp '/usr/xpg4/bin/cp -i'
if (-x /usr/xpg4/bin/mv) alias mv '/usr/xpg4/bin/mv -i'
if (-x /usr/xpg4/bin/rm) alias rm '/usr/xpg4/bin/rm -i'

unalias make

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
else if ($HOST == yugo) then
    alias	start_task	start_task -d /ws/haap
    alias	mkview		mkview -s /ws/haap
endif
alias	tagit		ct mklabel -replace BUILD
alias	cc_rmview	cc_rmview -view 
alias	mksp		nice make -j8 c6s2p2_sp-spv-mz -C /vob/ios/sys/obj-4k-apollo_plus
alias	mkrp		nice make -j8 c6sup2_rp-jk9sv-mz -C /vob/ios/sys/obj-4k-draco2-mp

if (-x /auto/ncsoft14/const/bin/easy_sa) then
    alias	easy_sa		/auto/ncsoft14/const/bin/easy_sa
endif
if (-x /auto/ncsoft14/const/bin/easy_prep) then
    alias	easy_prep	/auto/ncsoft14/const/bin/easy_prep
endif

if ($?tcsh) then
    if (-X emacs21) then
        alias	emacs	emacs21
    endif
endif
alias	r1		telnet cscpm10 2002
alias	r1-ch		telnet cscpm10 2007
alias	r1-mcpu		telnet cscpm10 2008
alias	r2		telnet cscpm10 2010
alias	r2-ch		telnet cscpm10 2013
alias	r2-mcpu		telnet cscpm10 2016
alias	r2-ocpu		telnet cscpm10 2005
alias	r2-icpu		telnet cscpm10 2004

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
            cd /vob/ios/sys
        endif
    endif
    setenv PROMPT_MACHNAME "`echo $CLEARCASE_ROOT | sed -e 's/\/view\///'`"
else
    setenv PROMPT_MACHNAME $MACHNAME
endif

if ($?TERM) then
    if ($TERM == "xterm-color") then
        setenv TERM xterm
    endif
endif

if ($?TERMTYPE && ! $?QUIET_CSHRC) then
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

if ($?TERMTYPE && $?tcsh && ! $?QUIET_CSHRC) then
    if ($TERMTYPE == 'xterm' && -X resize && $SHLVL == 1) then
        eval `resize`
        set setterm
    endif
endif

set ellipsis

unset SYS
unset dotdir

setenv NOMOTD 
setenv NOFRM
setenv NOQUOTACHECK

setenv IXIA_VERSION 3.80.125

cstat "."

if ($?INTERACTIVE && $SHLVL == 1 && \
    -e /sw/packages/ccache/2.3-RC1/bin/setup-ccache) then
    setenv TEAMBUILDER_SYSTEM "cisco:cross"
    setenv TEAMBUILDER_C_EXTNS ".s,.S"
    setenv TEAMBUILDER_CPP_EXTNS ".ii"

    if ($?gatherpaths) then
        set C_PATH	= (/opt/teambuilder/bin ${C_PATH})
    endif

    if ($HOST != glenlivet) then
#         setenv CCACHE_GCC_FARM_PATH /opt/teambuilder/bin
#         source /sw/packages/ccache/2.3-RC1/bin/setup-ccache
#         if ($?gatherpaths) then
#             set C_PATH	= (/sw/packages/ccache/2.3-RC1/bin ${C_PATH})
#         endif
    endif
endif

cstat "done\n"
