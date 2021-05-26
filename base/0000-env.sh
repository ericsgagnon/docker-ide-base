#!/usr/bin/with-contenv bash

# this script keeps the container's environment
# and is intended for general system-wide configuation,
# including user setup by s6 in /etc/cont-init.d/ files.
# note that is intended for 'single user' or 'primary user'
# images.
# if you want to populate user env vars, append to /etc/skel/.bashrc
# during build or before users are created.
export USER_NAME=${USER_NAME:=liveware}
export USER_ID=${USER_ID:=1138}
export GROUP_NAME=${GROUP_NAME:=${USER_NAME}}
export GROUP_ID=${GROUP_ID:=${USER_ID}}
export GROUP_LIST=${GROUP_LIST:=''}
export USER_HOME=${USER_HOME:=/home/${USER_NAME}}
export PASSWORD_FILE=${PASSWORD_FILE:=''}
PASSWORD=${PASSWORD:=password}
if [[ -n ${PASSWORD_FILE} ]] ; then 
    #PASSWORD=$(cat ${PASSWORD_FILE} | tr -d '[:space:]' )
    PASSWORD=$(head -n 1 ${PASSWORD_FILE} | tr -d '[:space:]' )
fi
export PASSWORD
export UPDATE_PASSWORD=${UPDATE_PASSWORD:=false}
export ROOT=${ROOT:=true}


