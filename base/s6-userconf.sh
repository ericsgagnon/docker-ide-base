#!/usr/bin/with-contenv bash

## Set defaults for environmental variables in case they are undefined
USER=${USER:=liveware}
GROUP=${GROUP:=liveware}
GROUPS=${GROUPS:=''}
UPDATE_PASSWORD=${UPDATE_PASSWORD:=false}
PASSWORD_FILE=${PASSWORD_FILE:=''}
if [[ -n $PASSWORD_FILE ]] ; then 
    PASSWORD=$(cat $PASSWORD_FILE | tr -d '[:space:]' )
fi
PASSWORD=${PASSWORD:=password}
USERID=${USERID:=1138}
GROUPID=${GROUPID:=1138}
ROOT=${ROOT:=true}

# create group #######################################################
getent group $GROUP
if [ $? -ne 0 ] ; then
    echo "Creating Group $GROUP"
    groupadd -g $GROUPID $GROUP
else
    echo "Group $GROUP exists"
fi

# fix group id #######################################################
group_id=$(getent group $GROUP | awk -F: '{printf "%d\n", $3}')
if [ $group_id -ne $GROUPID ] ; then 
    echo "Correct group $GROUP's id from $group_id to $GROUPID"
    groupmod -g $GROUPID $GROUP
fi


# create user ########################################################
echo $GROUPS

getent passwd $USER &> /dev/null
if [ $? -ne 0 ] ; then
    echo "creating user: $USER"
    useradd \
    -u $USERID \
    -g $GROUP \
    -p "\"$PASSWORD\"" \
    -s /bin/bash \
    -m $USER
    echo "$USER:$PASSWORD" | chpasswd
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
else
    echo "User $USER already exists, skipping useradd"
fi

# add supplementary groups
# if [[ $ROOT ]] & [[ -n $GROUPS ]]; then
#     GROUPS="$GROUPS,root,sudo"
# elif [[ $ROOT ]] & [[ -z $GROUPS ]]; then 
#     GROUPS="root,sudo"
# fi

if [[ $ROOT ]] ; then
    GROUPS="$GROUPS,root,sudo"
fi

# always add staff supplemental group
GROUPS="$GROUPS,staff"
GROUPS=$(echo $(echo $GROUPS | tr ',' '\n' | grep -v '^$' | sort | uniq) | tr ' ' ',')

if [[ -n $GROUPS ]]; then
    usermod -aG $GROUPS $USER
fi

# update password
if [ $UPDATE_PASSWORD ] ; then
    #usermod -p "\"$PASSWORD\"" $USER
    #echo -e "$PASSWORD\n$PASSWORD" | passwd  $USER
    echo "$USER:$PASSWORD" | chpasswd
fi

# update user id 
user_id=$(id -u $USER)
if [ $user_id -ne $USERID ] ; then 
    echo "Correct user $USER's id from $user_id to $USERID"
    usermod -u $USERID $USER
fi

