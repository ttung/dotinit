umask 022

if ( $?VISUAL == 0 ) then
    setenv VISUAL emacs
endif
if ( $?NNTPSERVER == 0 ) then
    setenv NNTPSERVER usenet.cisco.com
endif

set USER_PATH=
if ( $?SETPATHS ) then
    setenv PATH /bin:/usr/bin:.
endif
setenv OS_PATH "/bin /usr/bin"		# "Always" correct. -ljr
setenv MANPATH /usr/man

set SYS="`uname -s`"
set dotdir = ${HOME}/.files
if ( $SYS != "" ) then
    set osenv=${dotdir}/${SYS}/cshenv
    if ( -f $osenv ) source $osenv
    pstat "."

    # Some of these variables are set up by sub-scripts.
    if ( $?SETPATHS ) then
        set path=( $SW_PATH $APPS_PATH $LOCAL_PATH    \
                    $USER_PATH $OS_PATH . )
    endif
    unset osenv
endif

setenv CSHENV_SET true

# initialize path variables for HOME subsystem
if ($?SETPATHS) then
    if ($?HOME) then
        if (-d $HOME/software/bin) then
            setenv PATH     "${HOME}/software/bin:${PATH}"
        endif

        if (-d $HOME/software/bin-${MACHTYPE}-${OSTYPE}) then
            setenv PATH     "${HOME}/software/bin-${MACHTYPE}-${OSTYPE}:${PATH}"
        endif

        if (-d $HOME/software/man) then
            setenv MANPATH  "${MANPATH}:${HOME}/software/man"
        endif

        if (-d $HOME/software/man-${MACHTYPE}-${OSTYPE}) then
            setenv MANPATH  "${MANPATH}:${HOME}/software/man-${MACHTYPE}-${OSTYPE}"
        endif
    endif

    if (-d /usr/atria/doc/man) then
        setenv MANPATH "${MANPATH}:/usr/atria/doc/man"
    endif

    if (-d /asi/local/bin) then
        setenv PATH "${PATH}:/asi/local/bin"
    endif

    if (-d /usr/local/sbtools/x86-linux-rh6.0/mips64-sb1sim-2.1.1) then
        setenv SBTOOLS_BASE /usr/local/sbtools/x86-linux-rh6.0/mips64-sb1sim-2.1.1
    else if (-d /vws/xnw/sbtools/sparc-solaris-5.6/mips64-sb1sim-2.3.1) then
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
endif

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
alias	ct	cleartool
alias	lsv	'ct lsview | grep ${user}'
alias	ctvstat	ct lscheckout -cview -avobs
alias	ctstat	'ctvstat | grep checkout | sed -e '\''s/[^\"]*\"\([^\"]*\)\".*/\1/'\'
alias	ctdiff	ct diff -pre
alias	start_task	start_task -v /vob/ace -d /vws/xel
alias	mkview	mkview -v /vob/ace -s /vws/xel
alias	tagit	ct mklabel -replace BUILD
alias	cc_rmview	cc_rmview -vob /vob/ace -view 

# disable copyright check on clearcase
setenv	CC_DISABLE_COPYRIGHT_CHECK

# alias to ssh1
alias ssh-add         ssh-add1
alias ssh-agent       ssh-agent1

if ($?LESSOPEN) unsetenv LESSOPEN

if ($?tcsh) then
    complete	ct			'p/1/( describe diff lshistory lsvtree man mkelem pwv setview )/'
    complete	cleartool		'p/1/( describe diff lshistory lsvtree man mkelem pwv setview )/'
    complete	ssh			'p/1/( cryptonite-lnx ptooie needles dundee )/' 
endif

if ($?CLEARCASE_ROOT && $?INTERACTIVE) then
    if (! $?EMACS) then
        cd /vob/ace
    endif
    setenv USR_CLR "`echo $CLEARCASE_ROOT | sed -e 's/\/view\///'`"
else
    setenv USR_CLR $HOST
endif

if ($?TERM) then
    if ($?tcsh) then
        if ($?WINDOW) then 
            setenv WINDOW_NUM ":$WINDOW"
        else
            setenv WINDOW_NUM 
        endif

        if ($TERM == xterm || $TERM == screen) then
            set prompt='%{\e]0\;['${USR_CLR}${WINDOW_NUM}'] \!:%c03>^g%}['${USR_CLR}${WINDOW_NUM}'] \!:%B%c03%b%# '
        else
            set prompt='['${USR_CLR}${WINDOW_NUM}'] \!:%B%c03%b%# '
        endif
    else
        set prompt='[\!] '
    endif
endif
set ellipsis

unset SYS
unset dotdir

setenv NOMOTD 
setenv NOFRM
setenv NOQUOTACHECK

pstat "done\n"
