#!/bin/bash
# populate environment variables using /etc/profile.d/base-env.sh ####
# s6 captures container env vars and saves them in /run/s6/container_environment.
# each var's name is the filename and the first line is the value of the var.

echo "#!/bin/bash"                                                                          >  /etc/profile.d/base-env.sh
echo "# this file is auto generated on container start/restart by s6-overlay. do not edit." >> /etc/profile.d/base-env.sh
echo 'export HOME=$(getent passwd $(whoami) | cut -f6 -d:)'                                 >> /etc/profile.d/base-env.sh

tempfile=$(mktemp)
env_dir=/run/s6/container_environment/
env_vars=$(ls $env_dir | xargs -I {} echo {} | grep -v -e "^HOME$" | grep -v "^CWD$" | grep -v "^USER$" | grep -v "^WORKSPACE$" )
for f in $env_vars; do
    #echo "$env_dir$f"    
    echo "export $f=\"$(cat $env_dir$f)\"" >> $tempfile
done

# sort and remove duplicates
cat $tempfile | sort | uniq | tee -a /etc/profile.d/base-env.sh &>/dev/null
# cleanup
rm -f $tempfile
