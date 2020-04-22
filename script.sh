#!/bin/bash

missing_env_var_secret=false

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


#if missing env var or secret => exit
if [[ $missing_env_var_secret = true ]]; then
  exit 1
else
   echo -e "all secrets and all env var \e[92mOK\e[0m"
fi


# extract the protocol
proto="$(echo $KHEOPS_ROOT_URL | grep :// | sed -e's,^\(.*://\).*,\1,g')"
# remove the protocol
url="$(echo ${KHEOPS_ROOT_URL/$proto/})"
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

echo $proto
echo $url
echo $user
echo $hostport
echo $host
echo $port
echo $path


roothost="$(awk -F/ '{sub("^[^@]+@","",$3); print $3}' <<<$KHEOPS_ROOT_URL)"

#get env var
chmod a+w /etc/nginx/conf.d/kheops.conf
sed -i "s|\${root_url}|$proto://$host|" /etc/nginx/conf.d/kheops.conf

sed -i "s|\${DICOMWebProxy_url}|$KHEOPS_DICOMWEB_PROXY_HOST:$KHEOPS_DICOMWEB_PROXY_PORT|" /etc/nginx/conf.d/kheops.conf
sed -i "s|\${kheopsAuthorization_url}|http://$KHEOPS_AUTHORIZATION_HOST:$KHEOPS_AUTHORIZATION_PORT|" /etc/nginx/conf.d/kheops.conf
sed -i "s|\${kheopsAuthorizationProxy_url}|http://$KHEOPS_PACS_PEP_HOST:$KHEOPS_PACS_PEP_PORT|" /etc/nginx/conf.d/kheops.conf
sed -i "s|\${kheopsZipper_url}|http://$KHEOPS_ZIPPER_HOST:$KHEOPS_ZIPPER_PORT|" /etc/nginx/conf.d/kheops.conf
sed -i "s|\${kheopsWebUI_url}|http://$KHEOPS_UI_HOST:$KHEOPS_UI_PORT|" /etc/nginx/conf.d/kheops.conf

sed -i "s|\${server_name}|$roothost|" /etc/nginx/conf.d/kheops.conf

echo "Ending setup secrets and env var"

nginx-debug -g 'daemon off;'
