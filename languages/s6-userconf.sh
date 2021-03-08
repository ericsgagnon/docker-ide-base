
# languages ###################################################################

# install rust ##################################################
su - ${USER_NAME} -c '
which {rustup,cargo,rustc}
exit_status=$?
if [ $exit_status -ne 0 ] ; then 
    echo "Install rust"
    curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
fi
'

# install nvm,npm,node ##################################################
su - ${USER_NAME} -c '
which {nvm}
exit_status=$?
if [ $exit_status -ne 0 ] ; then 
    echo "Install nvm"    
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
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
