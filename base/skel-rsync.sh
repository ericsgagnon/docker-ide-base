#!/bin/bash

# this script propagates /etc/skel to user home directories 
# when logging in. It won't overwrite existing files, but 
# will copy deleted files if they exist in /etc/skel

echo "
-----------------------------------------------------------------------------------------------
copy /etc/skel to ${HOME}, skipping existing files (this will not overwrite any existing files)
-----------------------------------------------------------------------------------------------
 " \
&& rsync -rltD --ignore-existing /etc/skel/ ${HOME}/
