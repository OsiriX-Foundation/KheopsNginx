#!/bin/bash

missing_env_var_secret=false

#Verify secrets
if ! [ -f ${SECRET_FILE_PATH}/privkey1.pem ]; then
    echo "Missing privkey1.pem secret"
    missing_env_var_secret=true
else
   echo -e "secret privkey1.pem \e[92mOK\e[0m"
fi
if ! [ -f ${SECRET_FILE_PATH}/fullchain1.pem ]; then
    echo "Missing fullchain1.pem secret"
    missing_env_var_secret=true
else
   echo -e "secret fullchain1.pem \e[92mOK\e[0m"
fi


#Verify environment variables
if [[ -z $KHEOPS_ROOT_URL ]]; then
  echo "Missing KHEOPS_ROOT_URL environment variable"
  missing_env_var_secret=true
else
   echo -e "environment variable KHEOPS_ROOT_URL \e[92mOK\e[0m"
fi

if [[ -z $KHEOPS_DICOMWEB_PROXY_HOST ]]; then
  echo "Missing KHEOPS_DICOMWEB_PROXY_HOST environment variable"
  missing_env_var_secret=true
else
   echo -e "environment variable KHEOPS_DICOMWEB_PROXY_HOST \e[92mOK\e[0m"
fi

if [[ -z $KHEOPS_DICOMWEB_PROXY_PORT ]]; then
  echo "Missing KHEOPS_DICOMWEB_PROXY_PORT environment variable"
  missing_env_var_secret=true
else
   echo -e "environment variable KHEOPS_DICOMWEB_PROXY_PORT \e[92mOK\e[0m"
fi

if [[ -z $KHEOPS_AUTHORIZATION_HOST ]]; then
  echo "Missing KHEOPS_AUTHORIZATION_HOST environment variable"
  missing_env_var_secret=true
else
   echo -e "environment variable KHEOPS_AUTHORIZATION_HOST \e[92mOK\e[0m"
fi

if [[ -z $KHEOPS_AUTHORIZATION_PORT ]]; then
  echo "Missing KHEOPS_AUTHORIZATION_PORT environment variable"
  missing_env_var_secret=true
else
   echo -e "environment variable KHEOPS_AUTHORIZATION_PORT \e[92mOK\e[0m"
fi

if [[ -z $KHEOPS_PACS_PEP_HOST ]]; then
  echo "Missing KHEOPS_PACS_PEP_HOST environment variable"
  missing_env_var_secret=true
else
   echo -e "environment variable KHEOPS_PACS_PEP_HOST \e[92mOK\e[0m"
fi

if [[ -z $KHEOPS_PACS_PEP_PORT ]]; then
  echo "Missing KHEOPS_PACS_PEP_PORT environment variable"
  missing_env_var_secret=true
else
   echo -e "environment variable KHEOPS_PACS_PEP_PORT \e[92mOK\e[0m"
fi

if [[ -z $KHEOPS_ZIPPER_HOST ]]; then
  echo "Missing KHEOPS_ZIPPER_HOST environment variable"
  missing_env_var_secret=true
else
   echo -e "environment variable KHEOPS_ZIPPER_HOST \e[92mOK\e[0m"
fi

if [[ -z $KHEOPS_ZIPPER_PORT ]]; then
  echo "Missing KHEOPS_ZIPPER_PORT environment variable"
  missing_env_var_secret=true
else
   echo -e "environment variable KHEOPS_ZIPPER_PORT \e[92mOK\e[0m"
fi

if [[ -z $KHEOPS_UI_HOST ]]; then
  echo "Missing KHEOPS_UI_HOST environment variable"
  missing_env_var_secret=true
else
   echo -e "environment variable KHEOPS_UI_HOST \e[92mOK\e[0m"
fi

if [[ -z $KHEOPS_UI_PORT ]]; then
  echo "Missing KHEOPS_UI_PORT environment variable"
  missing_env_var_secret=true
else
   echo -e "environment variable KHEOPS_UI_PORT \e[92mOK\e[0m"
fi

if [[ -z $KHEOPS_OIDC_PROVIDER ]]; then
  echo "Missing KHEOPS_OIDC_PROVIDER environment variable"
  missing_env_var_secret=true
else
   echo -e "environment variable KHEOPS_OIDC_PROVIDER \e[92mOK\e[0m"
fi

#if missing env var or secret => exit
if [[ $missing_env_var_secret = true ]]; then
  exit 1
else
   echo -e "all nginx secrets and all env var \e[92mOK\e[0m"
fi


# extract the protocol
proto="$(echo $KHEOPS_OIDC_PROVIDER | grep :// | sed -e's,^\(.*://\).*,\1,g')"
# remove the protocol
url="$(echo ${KHEOPS_OIDC_PROVIDER/$proto/})"
# extract the user (if any)
user="$(echo $url | grep @ | cut -d@ -f1)"
# extract the host and port
hostport="$(echo ${url/$user@/} | cut -d/ -f1)"
# by request host without port    
host="$(echo $hostport | sed -e 's,:.*,,g')"
# by request - try to extract the port
port="$(echo $hostport | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
# extract the path (if any)
path="$(echo $url | grep / | cut -d/ -f2-)"

roothost="$(awk -F/ '{sub("^[^@]+@","",$3); print $3}' <<<$KHEOPS_ROOT_URL)"

#get env var
chmod a+w /etc/nginx/conf.d/kheops.conf
sed -i "s|\${root_url}|$KHEOPS_ROOT_URL|g" /etc/nginx/conf.d/kheops.conf

sed -i "s|\${DICOMWebProxy_url}|http://$KHEOPS_DICOMWEB_PROXY_HOST:$KHEOPS_DICOMWEB_PROXY_PORT|g" /etc/nginx/conf.d/kheops.conf
sed -i "s|\${kheopsAuthorization_url}|http://$KHEOPS_AUTHORIZATION_HOST:$KHEOPS_AUTHORIZATION_PORT|g" /etc/nginx/conf.d/kheops.conf
sed -i "s|\${kheopsAuthorizationProxy_url}|http://$KHEOPS_PACS_PEP_HOST:$KHEOPS_PACS_PEP_PORT|g" /etc/nginx/conf.d/kheops.conf
sed -i "s|\${kheopsZipper_url}|http://$KHEOPS_ZIPPER_HOST:$KHEOPS_ZIPPER_PORT|g" /etc/nginx/conf.d/kheops.conf
sed -i "s|\${kheopsWebUI_url}|http://$KHEOPS_UI_HOST:$KHEOPS_UI_PORT|g" /etc/nginx/conf.d/kheops.conf

sed -i "s|\${server_name}|$roothost|g" /etc/nginx/conf.d/kheops.conf
sed -i "s|\${keycloak_url}|$proto$hostport|g" /etc/nginx/conf.d/kheops.conf

echo "Ending setup NGINX secrets and env var"

#######################################################################################
#ELASTIC SEARCH

if ! [ -z "$KHEOPS_REVERSE_PROXY_ENABLE_ELASTIC" ]; then
    if [ "$KHEOPS_REVERSE_PROXY_ENABLE_ELASTIC" = true ]; then

        echo "Start init filebeat"
        missing_env_var_secret=false
        
       if [[ -z $KHEOPS_REVERSE_PROXY_ELASTIC_INSTANCE ]]; then
          echo "Missing KHEOPS_REVERSE_PROXY_ELASTIC_INSTANCE environment variable"
          missing_env_var_secret=true
        else
           echo -e "environment variable KHEOPS_REVERSE_PROXY_ELASTIC_INSTANCE \e[92mOK\e[0m"
           sed -i "s|\${instance}|$KHEOPS_REVERSE_PROXY_ELASTIC_INSTANCE|" /etc/filebeat/filebeat.yml
        fi

        if [[ -z $KHEOPS_REVERSE_PROXY_LOGSTASH_URL ]]; then
          echo "Missing KHEOPS_REVERSE_PROXY_LOGSTASH_URL environment variable"
          missing_env_var_secret=true
        else
           echo -e "environment variable KHEOPS_REVERSE_PROXY_LOGSTASH_URL \e[92mOK\e[0m"
           sed -i "s|\${logstash_url}|$KHEOPS_REVERSE_PROXY_LOGSTASH_URL|" /etc/filebeat/filebeat.yml
        fi

        #if missing env var or secret => exit
        if [[ $missing_env_var_secret = true ]]; then
          exit 1
        else
           echo -e "all elastic secrets and all env var \e[92mOK\e[0m"
        fi

        filebeat modules disable system

        service filebeat restart

        echo "Ending setup FILEBEAT"
    fi
else
    echo "[INFO] : Missing KHEOPS_REVERSE_PPROXY_ENABLE_ELASTIC environment variable. Elastic is not enable."
fi

#######################################################################################

nginx -g 'daemon off;'
