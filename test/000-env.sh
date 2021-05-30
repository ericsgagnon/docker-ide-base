#!/bin/bash

# this script uses s6's env directory to populate env vars
s6_env_file=/run/s6/container_environment/
env_file=$(cat ${s6_env_file}/ENV_FILE)

# if env file doesn't exist, create it
if [ ! -f ${env_file} ]; then
    echo "#!/bin/bash" >> ${env_file}
fi

# use s6's container_environment directory
s6_envs=$(ls -A /run/s6/container_environment/ | sed -E "s/^(HOME)|(CWD)|(HOSTNAME)|(WORKSPACE)$//g" )
echo "# s6 container envs ###########################################################" >> ${env_file}
for s6_env in ${s6_envs}; do    
    echo "export ${s6_env}=\"$(cat /run/s6/container_environment/${s6_env})\""         >> ${env_file}
done
echo "###############################################################################" >> ${env_file}

# setup user bash to source the env file
#echo "source ${env_file}" >> /etc/skel/.bashrc

source ${env_file}



