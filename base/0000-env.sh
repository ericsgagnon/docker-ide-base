#!/bin/bash

# XDG variables ####################################################### 
export XDG_CONFIG_HOME=${HOME}/.config
export XDG_CACHE_HOME=${HOME}/.cache
export XDG_DATA_HOME=${HOME}/.local/share

# use s6's container_environment directory ##########################################################
s6_envs=$(ls -A /run/s6/container_environment/ | sed -E "s/^(HOME)|(CWD)|(HOSTNAME)|(WORKSPACE)$//g" )

for s6_env in ${s6_envs}; do    
    if [[ ${s6_env} == "PATH" ]] ; then
        export ${s6_env}=$(cat /run/s6/container_environment/${s6_env}):"'${PATH}'"
        #echo $PATH | awk 'BEGIN{ RS=":" }{ print $0 }' | awk '!a[$0]++' | awk '!/^[[:space:]]*$/' | sed ':a;N;$!ba;s/\n/:/g'
        #echo ${s6_env} | awk 'BEGIN{ RS=":" }{ print $0 }' | awk '!a[$0]++' | awk '!/^[[:space:]]*$/' | sed ':a;N;$!ba;s/\n/:/g'  >> ${env_file}
    else 
        export ${s6_env}=$(cat /run/s6/container_environment/${s6_env})
    fi
done
