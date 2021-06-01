
# languages ###################################################################

echo '

# languages ###################################################################

# R 
export R_VERSION=$(R --version | grep -E "^R version " | sed -r "s/^R version ([[:digit:]]+\\.[[:digit:]]).*/\\1/g" )

# python virtualenvs default directory
export WORKON_HOME=${XDG_CACHE_HOME}/virtualenvs

# go envs
export GOPATH=${XDG_DATA_HOME}/go
export GOBIN=${HOME}/.local/bin/go
export PATH=/usr/local/go/bin:${PATH}

# nvm/npm
export NVM_DIR=${XDG_DATA_HOME}/nvm
export npm_config_userconfig=${XDG_CONFIG_HOME}/npm/npmrc
export npm_config_cache=${XDG_CACHE_HOME}/npm
export npm_config_init_module=${XDG_CONFIG_HOME}/npm/npm-init.js

# yarn
export YARN_RC_FILENAME=${XD_CONFIG_HOME}/yarn/yarnrc
export YARN_CACHE_FOLDER=${XDG_CACHE_HOME}/yarn

# rust doesnt like system-wide, just configuring env vars 
export RUSTUP_HOME=${XDG_DATA_HOME}/rustup
export CARGO_HOME=${XDG_DATA_HOME}/cargo
###############################################################################

' >> ${env_file}

###############################################################################

