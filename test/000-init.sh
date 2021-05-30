# #!/bin/bash

# # if env file doesn't exist, create it
# env_file=/etc/profile.d/0000-env.sh
# if [ ! -f ${env_file} ]; then
#     echo "#!/bin/bash" >> ${env_file}
# fi

# # capture s6 env files
# s6_envs=$(ls -A /run/s6/container_environment/ | sed -E "s/^(HOME)|(CWD)|(HOSTNAME)|(WORKSPACE)$//g" )
# echo "# s6 container envs ###########################################################" >> ${env_file}
# for s6_env in ${s6_envs}; do    
#     echo "export ${s6_env}=$(cat /run/s6/container_environment/${s6_env})"             >> ${env_file}
# done
# echo "###############################################################################" >> ${env_file}

























# capture env directives from dockerfile
# docker_envs=$(awk 'BEGIN { FS = "[= ]" } ; { if ($1 == "ENV") { print $2 } }' ${WORKSPACE}/Dockerfile | sort )

# propagate s6 env's that are in dockerfile
# useful to avoid propagating $HOME and other user-specific env's that could 
# cause issues in user setup scripts
# for docker_env in ${docker_envs}; do
#     for s6_env in ${s6_envs}; do
#         if [[ ${docker_env} == ${s6_env} ]] ; then
#             #echo ${s6env}
#             echo "export ${s6_env}=$(cat /run/s6/container_environment/${s6_env})" >> ${env_file}
#         fi
#     done
# done

#echo $(ls -A /run/s6/container_environment/ | sed -E "s/^(HOME)|(CWD)|(HOSTNAME)|(WORKSPACE)$//g" )

#do if ! [[ ${s6_env} == "HOME" ]] ; then echo ${s6_env}  fi  done


#!/bin/bash

# if env file doesn't exist, create it
# env_file=/etc/profile.d/0000-env.sh
# if [ ! -f ${env_file} ]; then
#     echo "#!/bin/bash" >> ${env_file}
# fi

# # capture env directives from dockerfile
# # docker_envs=$(awk 'BEGIN { FS = "[= ]" } ; { if ($1 == "ENV") { print $2 } }' ${WORKSPACE}/Dockerfile | sort )
# # capture s6 env files
# #s6_envs=$(ls /run/s6/container_environment)
# s6_envs=$(ls -A /run/s6/container_environment/ | sed -E "s/^(HOME)|(CWD)|(HOSTNAME)|(WORKSPACE)$//g" )

# #echo ${s6_envs}
# echo "-------------------------------------------------------------------------------"

# for s6_env in ${s6_envs}; do
#     echo ${s6_env}
#     echo "export ${s6_env}=$(cat /run/s6/container_environment/${s6_env})" >> ${env_file}
# done
# echo "-------------------------------------------------------------------------------"
