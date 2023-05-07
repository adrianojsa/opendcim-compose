FROM php:7.4-apache-bullseye

ARG OPENDCIMPATH=https://github.com/samilliken/openDCIM/archive/
ARG VER=21.01
ARG OPENDCIMFILE=$VER.tar.gz

RUN sed -i 's/bullseye\/updates main/bullseye\/updates main contrib non-free/' /etc/apt/sources.list \
&& sed -i 's/bullseye main/bullseye main contrib non-free/' /etc/apt/sources.list  \
&& apt update && apt install -y -q --no-install-recommends \
snmp \
snmp-mibs-downloader \
graphviz \
libsnmp-dev \
libpng-dev \
libjpeg-dev \
locales \
libldap2-dev \
libzip-dev \
zip \
nano \
&& ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
&& ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
&& docker-php-ext-install pdo pdo_mysql gettext snmp gd zip ldap \
&& mkdir -p /var/www && cd /var/www \
&& wget -q $OPENDCIMPATH/$OPENDCIMFILE \
&& tar xzf $OPENDCIMFILE \
&& rm -f $OPENDCIMFILE \
&& mv /var/www/openDCIM-$VER /var/www/dcim \
&& cp /var/www/dcim/db.inc.php-dist /var/www/dcim/db.inc.php

#---Criando nova imagem para diminuir as camadas e copiar os diretórios da aplicação compilada para nova imagem. 

FROM php:7.4-apache-bullseye
LABEL mantainer="adriano_jsa@hotmail.com"

COPY --from=0 /var/www/dcim /var/www/dcim
COPY --from=0 /usr/local /usr/local

# Arquivo de configuração do apache
COPY apache2.conf /etc/apache2/apache2.conf

# Habilitar localização, verificar arquivo locale-gen para sua linguagem.
COPY locale.gen /etc

RUN sed -i 's/bullseye\/updates main/bullseye\/updates main contrib non-free/' /etc/apt/sources.list \
&& sed -i '$adeb http:\/\/ftp.de.debian.org/debian bullseye main' /etc/apt/sources.list \
&& sed -i 's/bullseye main/bullseye main contrib non-free/' /etc/apt/sources.list \
&& apt update && apt install -y -q --no-install-recommends \
snmp \
curl \
gettext \
snmp-mibs-downloader \
graphviz \
libsnmp-base libsnmp40 \
libpng16-16 \
libjpeg62-turbo \
locales \
nano \
libzip-dev \
&& ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
&& ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
&& a2enmod rewrite

# desabiita mensagens de erro na tela para evitar redirecionamento de falhas na instalação
RUN echo "display_errors = Off"  | tee /usr/local/etc/php/php.ini
COPY dcim.htaccess /var/www/dcim/.htaccess
COPY 000-default.conf /etc/apache2/sites-available
COPY default-ssl.conf /etc/apache2/sites-available

# Diretórios para armazenar imagens, figuras e reports na versão opendcim 21.01
RUN mkdir /var/www/dcim/assets

# declaração de volumes 
VOLUME ["/data"]

# Copia o script entrypoint para as configurações iniciais após iniciar o container
COPY entrypoint.sh /usr/local/bin
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
