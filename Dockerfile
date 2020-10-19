FROM nginx:stable

ENV SECRET_FILE_PATH=/run/secrets

COPY kheops.conf /etc/nginx/conf.d/kheops.conf
COPY locations.conf /etc/nginx/locations.conf
COPY script.sh /etc/nginx/conf.d/script.sh

CMD ["./etc/nginx/conf.d/script.sh"]
