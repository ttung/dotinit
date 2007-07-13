setenv F_NOQUOTACHECK
setenv F_NOMOTD

if ($?f_gatherpaths) then
    set C_PATH    = (/usr/local/python-2.5.0/bin ${C_PATH})
endif
