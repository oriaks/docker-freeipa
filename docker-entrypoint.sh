#!/bin/bash

case $1 in
  "apache2")
    exec /usr/sbin/apache2ctl -D FOREGROUND
    ;;
  "bind9")
    exec /usr/sbin/named -f -u bind
    ;;
  "certmonger")
    exec /usr/sbin/certmonger -L -S -p /var/run/certmonger.pid -n -d2
    ;;
  "dirsrv")
    mkdir -p "/var/log/dirsrv/slapd-$(echo ${DOMAIN} | tr '[a-z].' '[A-Z]-')"
    chown -R dirsrv:dirsrv "/var/log/dirsrv | tr '[a-z].' '[A-Z]-')"
    mkdir -p "/var/lock/dirsrv/slapd-$(echo ${DOMAIN} | tr '[a-z].' '[A-Z]-')"
    chown -R dirsrv:dirsrv "/var/lock/dirsrv | tr '[a-z].' '[A-Z]-')"
    exec /usr/sbin/ns-slapd -D "/etc/dirsrv/slapd-$(echo ${DOMAIN} | tr '[a-z].' '[A-Z]-')" -i "/var/run/dirsrv/slapd-$(echo ${DOMAIN} | tr '[a-z].' '[A-Z]-').pid" -w "/var/run/dirsrv/slapd-$(echo ${DOMAIN} | tr '[a-z].' '[A-Z]-').startpid" -d0
    ;;
  "ipa-server-install")
    ipa-server-install \
      --realm "$(echo ${DOMAIN} | tr '[a-z]' '[A-Z]')" \
      --domain "${DOMAIN}" \
      --ds-password "${DS_PASSWORD}" \
      --master-password "${MASTER_PASSWORD}" \
      --admin-password "${ADMIN_PASSWORD}" \
      --mkhomedir \
      --hostname "${HOST}" \
      --no-ntp \
      --idstart "${IDSTART}" \
      --idmax "${IDMAX}" \
      --no-host-dns \
      --unattended
    cp -Rp /etc/apache2 /mnt/docker-volumes/freeipa/apache2
    cp -Rp /etc/bind /mnt/docker-volumes/named/config
    cp -Rp /etc/dirsrv /mnt/docker-volumes/389ds/config
    cp -Rp /etc/dogtag /mnt/docker-volumes/pki/dogtag
    cp -Rp /etc/ipa /mnt/docker-volumes/freeipa/ipa
    cp -Rp /etc/krb5kdc /mnt/docker-volumes/krb5/config
    cp -Rp /etc/krb5.conf /mnt/docker-volumes/krb5/krb5.conf
    cp -Rp /etc/krb5.keytab /mnt/docker-volumes/krb5/krb5.keytab
    cp -Rp /etc/pki /mnt/docker-volumes/pki/config
    cp -Rp /run /mnt/docker-volumes
    cp -Rp /var/lib/dirsrv /mnt/docker-volumes/389ds/data
    cp -Rp /var/lib/ipa/pki-ca /mnt/docker-volumes/pki/ca
    cp -Rp /var/lib/pki /mnt/docker-volumes/pki/data
    cp -Rp /var/log/pki /mnt/docker-volumes/pki/log
    ln -sf "slapd-$(echo ${DOMAIN} | tr '[a-z].' '[A-Z]-')" /etc/dirsrv/slapd
    ln -sf "slapd-$(echo ${DOMAIN} | tr '[a-z].' '[A-Z]-').pid" /var/run/dirsrv/slapd.pid
    ln -sf "slapd-$(echo ${DOMAIN} | tr '[a-z].' '[A-Z]-').startpid" /var/run/dirsrv/slapd.startpid
    systemctl poweroff
    ;;
  "krb5-admin-server")
    exec /usr/sbin/kadmind -nofork
    ;;
  "krb5-kdc")
    exec /usr/sbin/krb5kdc -P /var/run/krb5-kdc.pid -n
    ;;
  "memcached")
    exec /usr/bin/memcached -s /var/run/ipa_memcached/ipa_memcached -u www-data -m 64 -c 1024 -P /var/run/ipa_memcached/ipa_memcached.pid
    ;;
  "pki-tomcatd")
    export CATALINA_BASE="/var/lib/pki/pki-tomcat"
    export CATALINA_PID="/var/run/pki/tomcat/pki-tomcat.pid"
    export CATALINA_TMPDIR=/var/lib/pki/pki-tomcat/temp
    export JAVA_OPTS="-DRESTEASY_LIB=/usr/share/java/ -Djava.library.path=/usr/lib/jni"
    export PKI_PATH="/usr/share/pki/server"
    export PKI_REGISTRY="/etc/dogtag/tomcat"
    export PKI_TOTAL_PORTS=7
    export PKI_TYPE="tomcat"
    export PKI_VERSION=10.2.6
    export SECURITY_MANAGER="false"
    export TOMCAT_LOG="/var/log/pki/pki-tomcat/tomcat-initd.log"
    export TOMCAT_USER="pkiuser"
    export TOMCAT7_SECURITY="false"
    export TOMCAT7_USER="pkiuser"
    export USE_NUXWDOG="false"
    export command="start"
    export pki_instance_id="pki-tomcat"
    . /usr/share/pki/scripts/operations
    start
    sleep 9999999999999999999
    exit 0
    ;;
  "systemd")
    /lib/systemd/systemd
    ;;
esac

exec $@
