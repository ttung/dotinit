umask 022

if ( $?VISUAL == 0 ) then
    setenv VISUAL "$EDITOR"
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
endif

setenv CVSROOT /wbu-sw/dev/synergy

alias	quake	'finger -l quake@quake.geo.berkeley.edu'
alias	stock	'finger stocks@qotd2.cisco.com | egrep -i "^Company|^cisco|quotes" | head -3'

# clearcase aliases
alias	ct	cleartool
alias	lsv	'ct lsview | grep ${user}'
alias	ctstat	ct lscheckout -cview -avobs
alias	ctdiff	ct diff -pre
alias	start_task	start_task -v /vob/ace -d /vws/xel
alias	mkview	mkview -v /vob/ace -s /vws/xel
alias	tagit	ct mklabel -replace BUILD
alias	cc_rmview	cc_rmview -vob /vob/ace -view 

# disable copyright check on clearcase
setenv	CC_DISABLE_COPYRIGHT_CHECK

complete	ct			'p/1/( describe diff lshistory lsvtree mklabel setview )/'
complete	cleartool		'p/1/( describe diff lshistory lsvtree mklabel setview )/'

unset SYS
unset dotdir

if ($?CLEARCASE_ROOT && $?INTERACTIVE) then
    cd /vob/ace
endif
