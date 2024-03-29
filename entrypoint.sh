#! /bin/sh


if [ ! -f /.configured ] ; then
	# configure port with environment var DBHOST
	sed -i "s/getenv('OPENDCIM_DB_HOST'):'localhost'/\getenv('OPENDCIM_DB_HOST'):'$DBHOST'/" /var/www/dcim/db.inc.php
	sed -i "s/getenv('OPENDCIM_DB_NAME'):'dcim'/\getenv('OPENDCIM_DB_NAME'):'$DCIM_DB_SCHEMA'/" /var/www/dcim/db.inc.php
	sed -i "s/getenv('OPENDCIM_DB_USER'):'dcim'/\getenv('OPENDCIM_DB_USER'):'$DCIM_DB_USER'/" /var/www/dcim/db.inc.php
	sed -i "s/getenv('OPENDCIM_DB_PASS'):'dcim'/\getenv('OPENDCIM_DB_PASS'):'$DCIM_DB_PASSWD'/" /var/www/dcim/db.inc.php

	if [ -f "$SSL_CERT_FILE" ] && [ -f "$SSL_KEY_FILE" ] ; then
		a2enmod ssl
		a2ensite default-ssl
		cd /etc/ssl/certs/
		cp $SSL_CERT_FILE ssl-cert.pem
		cp $SSL_KEY_FILE ssl-cert.key
	fi

	# for swarm secret
	if [ -f "$DCIM_PASSWD_FILE" ] ; then
		PASSWORD=$(cat $DCIM_PASSWD_FILE)
	elif [ ! -z "$DCIM_PASSWD" ] ; then
		PASSWORD=$DCIM_PASSWD
	else
		PASSWORD=dcim
	fi
	htpasswd -cb /data/opendcim.password dcim $PASSWORD

	cd /var/www/dcim
	for D in images ; do
		if [ ! -d /data/$D ] ; then
			mkdir /data/$D
		fi

		if [ -d /var/www/dcim/$D ] ; then
			mv /var/www/dcim/$D/* /data/$D
			rm -rf /var/www/dcim/$D
                        ln -s /data/$D .
		fi

                chown www-data:www-data /data/$D
	done

	cd /var/www/dcim/assets
	for D in pictures drawings reports ; do
		if [ ! -d /data/$D ] ; then
			mkdir /data/$D
		fi

		if [ ! -d /var/www/dcim/assets/$D ] ; then
			ln -s /data/$D .
                fi

		chown www-data:www-data /data/$D
	done

	# fix permissions on images directory
	chmod -R 755 /data/images
	chmod -R 755 /data/drawings
	chmod -R 755 /data/pictures
	chown www-data:www-data /var/www/dcim/vendor/mpdf/mpdf/ttfontdata

	touch /.configured
fi

for param in "$@" ; do
	if [ "$param" = "--remove-install" ] ; then 
		rm -f /var/www/dcim/install.php
	elif [ "$param" = "--enable-ldap" ] ; then
		mv /var/www/dcim/.htaccess /var/www/dcim/.htaccess.no
		sed -i "s/Apache/LDAP/" /var/www/dcim/db.inc.php
	fi
done

exec docker-php-entrypoint -DFOREGROUND
