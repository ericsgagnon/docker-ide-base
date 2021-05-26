
# languages stage: ####################################################
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

##########################################################################


