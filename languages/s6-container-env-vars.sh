
# add env vars to R
#cat /etc/profile.d/base-env.sh | grep -E "^export " | sed -e "s/^export //g" | tee /etc/R/Renviron.site
renviron_site=/usr/local/lib/R/etc/Renviron.site
echo "# Renviron site file, created on container start/restart - do not edit."                    >  $renviron_site
echo "R_VERSION=${R_VERSION}"                                                                     >> $renviron_site
cat /etc/profile.d/base-env.sh | grep -E "^export " | sed -e "s/^export //g" | grep -v -E "^HOME" >> $renviron_site
echo ""                                                                                           >> $renviron_site
echo ""                                                                                           >> $renviron_site

