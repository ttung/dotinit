if [ "${t_setpaths}" = "yes" ]; then
    module load com.mysql.paths
fi
