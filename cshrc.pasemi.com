umask 022

alias	quake	'finger -l quake@quake.geo.berkeley.edu'

if ($?gatherpaths) then
    set C_PATH	= (${C_PATH} /proj/projroot/andromeda/bin \
                                /proj/cad/global_bin \
                                /proj/cad/scripts \
                                /tools/eda \
                                /tools/wrappers \
                                /tools/pas/devtools/1.0.1/i386-linux/bin \
                                /tools/pas/perfm/1.0.3/i386-linux/bin \
                                /tools/pas/twister/1.0.3/i386-linux/bin \
                                /tools/pas/tm/1.0.3/i386-linux/bin \
                                /tools/pas/tm/1.0.3/bin \
                                /tools/pas/imp/1.0.5/i386-linux/bin \
                                )
endif

setenv NOMOTD 
setenv NOFRM
setenv NOQUOTACHECK

if ($OSTYPE == "linux") then
    #######################################################
    # Common initialization
    source /proj/modules/init/csh
    module load pasemi/init

    #######################################################
    # Setup a project
    setup_project andromeda
endif

setenv PRINTER		chuck
setenv PASEMI_PATH	"${PATH}"

if ($OSTYPE == "darwin") then
    setenv DISPLAY :0
endif

cstat "done\n"
