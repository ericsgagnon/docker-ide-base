#!/bin/bash

# this script propagates /etc/skel to user home directories 
# when logging in. It won't overwrite existing files, but 
# will copy deleted files if they exist in /etc/skel

rsync -rltD --ignore-existing /etc/skel/ ${HOME}/
