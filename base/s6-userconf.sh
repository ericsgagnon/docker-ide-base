#!/usr/bin/with-contenv bash


## Set defaults for environmental variables in case they are undefined
USER_NAME=${USER_NAME:=liveware}
GROUP=${GROUP:=liveware}
GROUP_LIST=${GROUP_LIST:=''}
UPDATE_PASSWORD=${UPDATE_PASSWORD:=false}
PASSWORD_FILE=${PASSWORD_FILE:=''}
if [[ -n $PASSWORD_FILE ]] ; then 
    PASSWORD=$(cat $PASSWORD_FILE | tr -d '[:space:]' )
fi
PASSWORD=${PASSWORD:=password}
USER_HOME=${USER_HOME:=/home/$USER_NAME}
USER_ID=${USER_ID:=1138}
GROUP_ID=${GROUP_ID:=1138}
ROOT=${ROOT:=true}

# create group #######################################################
getent group $GROUP_NAME
if [ $? -ne 0 ] ; then
    echo "Creating Group $GROUP_NAME"
    groupadd -g $GROUP_ID $GROUP_NAME
else
    echo "Group $GROUP_NAME exists"
fi

# fix group id #######################################################
group_id=$(getent group $GROUP_NAME | awk -F: '{printf "%d\n", $3}')
if [ $group_id -ne $GROUP_ID ] ; then 
    echo "Correct group $GROUP_NAME's id from $group_id to $GROUP_ID"
    groupmod -g $GROUP_ID $GROUP_NAME
fi


# create user ########################################################
echo $GROUP_LIST

getent passwd $USER_NAME &> /dev/null
if [ $? -ne 0 ] ; then
    echo "Creating User: $USER_NAME"
    useradd \
    -u $USER_ID \
    -d $USER_HOME \
    -g $GROUP_NAME \
    -p "\"$PASSWORD\"" \
    -s /bin/bash \
    -m $USER_NAME
    echo "$USER_NAME:$PASSWORD" | chpasswd
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
else
    echo "User $USER_NAME already exists, skipping useradd"
fi

# add supplementary groups
# if [[ $ROOT ]] & [[ -n $GROUP_LIST ]]; then
#     GROUP_LIST="$GROUP_LIST,root,sudo"
# elif [[ $ROOT ]] & [[ -z $GROUP_LIST ]]; then 
#     GROUP_LIST="root,sudo"
# fi

if [[ $ROOT ]] ; then
    GROUP_LIST="$GROUP_LIST,root,sudo"
fi

# always add staff supplemental group
GROUP_LIST="$GROUP_LIST,staff"
GROUP_LIST=$(echo $(echo $GROUP_LIST | tr ',' '\n' | grep -v '^$' | sort | uniq) | tr ' ' ',')

if [[ -n $GROUP_LIST ]]; then
    usermod -aG $GROUP_LIST $USER_NAME
fi

# update password
if [ $UPDATE_PASSWORD ] ; then
    #usermod -p "\"$PASSWORD\"" $USER_NAME
    #echo -e "$PASSWORD\n$PASSWORD" | passwd  $USER_NAME
    echo "$USER_NAME:$PASSWORD" | chpasswd
fi

# update user id 
user_id=$(id -u $USER_NAME)
if [ $user_id -ne $USER_ID ] ; then 
    echo "Correct user $USER_NAME's id from $user_id to $USER_ID"
    usermod -u $USER_ID $USER_NAME
fi

