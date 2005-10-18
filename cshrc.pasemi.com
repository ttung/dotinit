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

    if ($OSTYPE == "linux" || $HOST == "cs-ppc64-1") then
        #######################################################
        # Common initialization
        source /proj/modules/init/csh
        module load pasemi/init
        module load pas

        #######################################################
        # Setup a project
        setup_project andromeda

        if ($?LESSOPEN) unsetenv LESSOPEN
    endif
    if ($OSTYPE == "mklinux") then
        setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/opt/ibmcmp/lib
    endif

    setenv PRINTER		hurl
    setenv PASEMI_PATH	"${PATH}"

    if ($OSTYPE == "darwin") then
        setenv DISPLAY :0
    endif

    cstat "done\n"
endif
