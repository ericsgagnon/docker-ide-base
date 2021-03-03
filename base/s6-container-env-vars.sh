#!/bin/bash
# populate environment variables using /etc/profile.d/base-env.sh ####
# s6 captures container env vars and saves them in /run/s6/container_environment.
# each var's name is the filename and the first line is the value of the var.

env_dir=/run/s6/container_environment/
env_vars=$(ls $env_dir | xargs -I {} echo {} | grep -v -e "^HOME$" | grep -v "^CWD$" | grep -v "^USER$" | grep -v "^WORKSPACE$" )
for f in $env_vars; do
    #echo "$env_dir$f"    
    echo "export $f=\"$(cat $env_dir$f)\"" >> /etc/profile.d/base-env.sh
done

# cleanup: remove duplicates, make sure path prepends
cat /etc/profile.d/base-env.sh | sort | uniq | \
    sed -E "s/^(export PATH=.+)/\\1:\$PATH/g" | \
    tee /etc/profile.d/base-env.sh



