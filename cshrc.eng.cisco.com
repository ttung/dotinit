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
setenv OS_PATH "/bin /usr/bin"# "Always" correct. -ljr
setenv MANPATH /usr/man

set SYS="`uname -s`"
set dotdir = ${HOME}/.files
if ( $SYS != "" ) then
    set osenv=${dotdir}/${SYS}/cshenv
    if ( -f $osenv ) source $osenv

    # Some of these variables are set up by sub-scripts.
    if ( $?SETPATHS != 0 ) then
        set path=( $SW_PATH $APPS_PATH $LOCAL_PATH\
                    $USER_PATH $OS_PATH . )
    endif
endif

setenv CSHENV_SET true
alias emacs '~immanuel/bin/emacs'
