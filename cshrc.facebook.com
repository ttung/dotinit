setenv F_NOQUOTACHECK
setenv F_NOMOTD

if ($?f_gatherpaths) then
    set C_PATH    = (${C_PATH} /home/engshare/admin/facebook/scripts /home/engshare/admin/scripts)
else
    alias use     "rm -f ~/work/www; ln -sf ~/work/www-\!* ~/work/www; echo using work/www-\!*"
    alias reset_err "sudo tcsh -c 'cat /dev/null >! ~ttung/logs/error_log_ttung'"

    complete use  'p@1@`ls -1d ~/work/www-* | sed -r '\''s/.*www-(.*)\//\1/'\''`@'

    if ($SHLVL == 1) then
        module load oss.pexpect
    endif
endif
