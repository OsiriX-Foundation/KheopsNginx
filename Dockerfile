FROM nginx:stable

ENV SECRET_FILE_PATH=/run/secrets

COPY kheops.conf /etc/nginx/conf.d/kheops.conf
COPY location.conf /etc/nginx/location.conf
COPY script.sh /etc/nginx/conf.d/script.sh

CMD ["./etc/nginx/conf.d/script.sh"]
