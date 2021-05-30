#!/usr/bin/with-contenv bash

# if env file doesn't exist, create it
env_file=/etc/profile.d/0000-env.sh
if [ ! -f ${env_file} ]; then
    echo "#!/bin/bash" >> ${env_file}
fi


# capture env directives from dockerfile
docker_envs=$(awk 'BEGIN { FS = "[= ]" } ; { if ($1 == "ENV") { print $2 } }' ${WORKSPACE}/Dockerfile | sort )
# capture s6 env files
s6_envs=$(ls /run/s6/container_environment)


# propagate s6 env's that are in dockerfile
# useful to avoid propagating $HOME and other user-specific env's that could 
# cause issues in user setup scripts
for docker_env in ${docker_envs}; do
    for s6_env in ${s6_envs}; do
        if [[ ${docker_env} == ${s6_env} ]] ; then
            #echo ${s6env}
            echo "export ${s6_env}=$(cat /run/s6/container_environment/${s6_env})" >> ${env_file}
        fi
    done
done


# for env in $(awk 'BEGIN { FS = "[= ]" } ; { if ($1 == "ENV") { print $2 } }' ${WORKSPACE}/Dockerfile | sort ); do
#     for s6env in $(ls /run/s6/container_environment); do
#         if [[ ${env} == ${s6env} ]] ; then
#             #echo ${s6env}
#             echo "export $env=$(cat /run/s6/container_environment/$s6env)"
#         fi
#     done
# done

# echo $(cat ${WORKSPACE}/Dockerfile |     grep -E "^ENV" |     sed -E "s/^ENV ([^=]+).+/\1/g" |     sort |     uniq )

# cat ${WORKSPACE}/Dockerfile | \
#     grep -E "^ENV" | \
#     sed -E "s/^ENV ([^=]+).+/\1/g" | \
#     sort | \
#     uniq |
#     echo

# awk "{print NF}" < pos_cut.txt | uniq

# cat ${WORKSPACE}/Dockerfile | \
# awk "{print NF}" 

# for env in $(awk 'BEGIN { FS = "[= ]" } ; { if ($1 == "ENV") { print $2 } }' ${WORKSPACE}/Dockerfile); do
# if $env in $(ls /run/s6/container_environment) 

# fi
# echo $env;
# done

# for env in $(awk 'BEGIN { FS = "[= ]" } ; { if ($1 == "ENV") { print $2 } }' ${WORKSPACE}/Dockerfile | sort ); do
#     if [[ $env in $(ls /run/s6/container_environment)  ]] ; then
#     echo "Common ${env}"    
# else
#     echo "Dockerbaby: ${env}"
# fi

# for s6env in $(ls /run/s6/container_environment); do
#     echo $s6env
# done

# for env in $(awk 'BEGIN { FS = "[= ]" } ; { if ($1 == "ENV") { print $2 } }' ${WORKSPACE}/Dockerfile | sort ); do
#     for s6env in $(ls /run/s6/container_environment); do
#         if [[ ${env} == ${s6env} ]] ; then
#             #echo ${s6env}
#             echo "export $env=$(cat /run/s6/container_environment/$s6env)"
#         fi
#     done
# done



# [[ "$WORD" =~ $(echo ^\($(paste -sd'|' /your/file)\)$) ]]

# cat ${WORKSPACE}/Dockerfile | awk 'BEGIN { FS = "[= ]" } ; { if ($1 == "ENV") { print $2 } }'





# cat ${WORKSPACE}/Dockerfile | \
# awk '{ if ($1 == "ENV") { print $2 } }' |
# awk 'BEGIN { FS = "=" } ; { print $1 }'



# awk '{ if ($1 == "ENV") { print $2 } }' |


# awk  -F "=" '{ print $1 }'

