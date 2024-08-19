#!/bin/bash

# XDG variables ####################################################### 
export XDG_CONFIG_HOME=${HOME}/.config
export XDG_CACHE_HOME=${HOME}/.cache
export XDG_DATA_HOME=${HOME}/.local/share

PATH=$(cat /run/s6/container_environment/PATH):${PATH}
export PATH=$(dedupe -i : -t i $PATH)
