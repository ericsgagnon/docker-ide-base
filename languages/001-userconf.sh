
# languages ###################################################################
export USER_XDG_CONFIG_HOME=${USER_HOME}/.config
export USER_XDG_CACHE_HOME=${USER_HOME}/.cache
export USER_XDG_DATA_HOME=${USER_HOME}/.local/share

# python virtualenvs default directory
export USER_WORKON_HOME=${USER_XDG_CACHE_HOME}/virtualenvs

# go env's
export USER_GOPATH=${USER_XDG_DATA_HOME}/go
export USER_GOBIN=${USER_HOME}/.local/bin/go

# nvm/npm
export USER_NVM_DIR=${USER_XDG_DATA_HOME}/nvm
export USER_npm_config_userconfig=${USER_XDG_CONFIG_HOME}/npm/npmrc
export USER_npm_config_cache=${USER_XDG_CACHE_HOME}/npm
export USER_npm_config_init_module=${USER_XDG_CONFIG_HOME}/npm/npm-init.js

# yarn
export USER_YARN_RC_FILENAME=${USER_XD_CONFIG_HOME}/yarn/yarnrc
export USER_YARN_CACHE_FOLDER=${USER_XDG_CACHE_HOME}/yarn

# rust doesn't like system-wide, just configuring env vars 
export USER_RUSTUP_HOME=${USER_XDG_DATA_HOME}/rustup
export USER_CARGO_HOME=${USER_XDG_DATA_HOME}/cargo

###############################################################################

# install rust ##################################################
su - ${USER_NAME} -c '
source ${HOME}/.bashrc

# export XDG_CONFIG_HOME=${USER_XDG_CONFIG_HOME}
# export XDG_CACHE_HOME=${USER_XDG_CACHE_HOME}
# export XDG_DATA_HOME=${USER_XDG_DATA_HOME}

# rust doesnt like system-wide, just configuring env vars 
# export RUSTUP_HOME=${USER_RUSTUP_HOME}
# export CARGO_HOME=${USER_CARGO_HOME}

which {rustup,cargo,rustc}
exit_status=$?
if [ $exit_status -ne 0 ] ; then 
    echo "Install rust"
    curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
fi
'

# install nvm,npm,node ##################################################
su - ${USER_NAME} -c '
source ${HOME}/.bashrc

# export XDG_CONFIG_HOME=${USER_XDG_CONFIG_HOME}
# export XDG_CACHE_HOME=${USER_XDG_CACHE_HOME}
# export XDG_DATA_HOME=${USER_XDG_DATA_HOME}


# # nvm/npm
# export NVM_DIR=${USER_NVM_DIR}
# export npm_config_userconfig=${USER_npm_config_userconfig}
# export npm_config_cache=${USER_npm_config_cache}
# export npm_config_init_module=${USER_npm_config_init_module}

# # yarn
# export YARN_RC_FILENAME=${USER_YARN_RC_FILENAME}
# export YARN_CACHE_FOLDER=${USER_YARN_CACHE_FOLDER}

which {nvm}
exit_status=$?
if [ $exit_status -ne 0 ] ; then 
    echo "Install nvm"    
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
fi

source ${NVM_DIR}/nvm.sh

which {node}
exit_status=$?
if [ $exit_status -ne 0 ] ; then 
    echo "Install node"    
    nvm install node
fi

which {npm}
exit_status=$?
if [ $exit_status -ne 0 ] ; then 
    echo "Install npm"    
    nvm install-latest-npm
fi

'

# homebrew ####################################################
# not sure if we should be using homebrew, it has an odd /home/linuxbrew install folder requirement 
# that appears to be baked into their compiled binaries. 
# su - ${USER_NAME} -c '
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# echo 'eval "$(${HOME}/.linuxbrew/bin/brew shellenv)"' >> ${HOME}/.profile
# '
