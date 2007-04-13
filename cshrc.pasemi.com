if ($?f_gatherpaths) then
    set C_PATH      = (${C_PATH} /proj/projroot/andromeda/bin \
                                /proj/cad/global_bin \
                                /proj/cad/scripts \
                                /tools/eda \
                                /tools/wrappers \
                                )
#                                /tools/pas/devtools/1.0.1/i386-linux/bin \
#                                /tools/pas/perfm/1.0.3/i386-linux/bin \
#                                /tools/pas/twister/1.0.3/i386-linux/bin \
#                                /tools/pas/tm/1.0.3/i386-linux/bin \
#                                /tools/pas/tm/1.0.3/bin \
#                                /tools/pas/imp/1.0.5/i386-linux/bin \
#
    if ($OSTYPE == "Linux") then
        set C_LD_LIBRARY_PATH = (${C_LD_LIBRARY_PATH} /tools/openssl/0.9.8a/Linux-i686/lib)
    endif
    if ("$MACHTYPE" == "ppc64" || $HOST == "orion-059") then
        set C_LD_LIBRARY_PATH = (${C_LD_LIBRARY_PATH} /opt/ibmcmp/lib /proj/sw/users/tonytung/ppc32-lib/xlc_xlf /proj/sw/users/tonytung/ppc32-lib/hugetlbfs)
    endif
else
    umask 022

    alias	quake	'finger -l quake@quake.geo.berkeley.edu'

    if ($OSTYPE == "darwin" && -e ${HOME}/mac/Emacs.app) then
        alias em ${HOME}/mac/Emacs.app/Contents/MacOS/Emacs
    else if (-x /opt/local/bin/emacs) then
        alias em /opt/local/bin/emacs
        alias emacs /opt/local/bin/emacs
        alias en /opt/local/bin/emacs -nw
    endif

    setenv F_NOMOTD 
    setenv F_NOFRM
    setenv F_NOQUOTACHECK

    if ($HOST != "orion-059" && ($OSTYPE == "Linux" || $HOST == "cs-ppc64-1")) then
        if ($?f_setpaths) then
            #######################################################
            # Common initialization
            source /proj/modules/init/csh
            module load pasemi/init
            module load pas
            module load firefox/1.5.0.1
        
            setenv MODULEPATH ${MODULEPATH}:${HOME}/software/modules
        
            setenv f_moduleload
            module load cscope/15.5
            module load emacs/22.0-20060622
            unsetenv f_moduleload
        
            #######################################################
            # Setup a project
            setup_project andromeda
        
            if ($?LESSOPEN) unsetenv LESSOPEN
        else
            setenv OLD_PATH ${PATH}
            source /proj/modules/init/csh
            module load pasemi/init
            module load pas
            setenv PATH ${OLD_PATH}
            unsetenv OLD_PATH
        endif
    endif
    if ($HOST != "escobita" && $HOST != "admin-3-4") then
        setenv F_NO_SSH_AUTH_SOCK
    endif
    setenv PRINTER		hurl
    setenv PASEMI_PATH	"${PATH}"

    if ($OSTYPE == "darwin") then
        setenv DISPLAY :0
    endif

    cstat "done\n"
endif
