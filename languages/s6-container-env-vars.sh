
# add env vars to R
cat /etc/profile.d/base-env.sh | grep -E "^export " | sed -e "s/^export //g" | envsubst | tee /etc/R/Renviron.site

cat /etc/R/Renviron.site  >>  /etc/skel/.config/R/.Renviron


