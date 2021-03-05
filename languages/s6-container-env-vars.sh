
# add env vars to R
#cat /etc/profile.d/base-env.sh | grep -E "^export " | sed -e "s/^export //g" | tee /etc/R/Renviron.site

su - $USER -c '
    cat /etc/profile.d/base-env.sh | 
    grep -E "^export "             | 
    sed -e "s/^export //g"         |
    sed -E "s/~/\$HOME/g"          | 
    envsubst >> $HOME/.config/R/.Renviron
'

#cat /etc/R/Renviron.site |  sed -E "s/~/\$HOME/g" | envsubst >> $HOME/.config/R/.Renviron'
