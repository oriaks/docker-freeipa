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
    exec /usr/sbin/ns-slapd -D /etc/dirsrv/slapd -i /var/run/dirsrv/slapd.pid -w /var/run/dirsrv/slapd.startpid -d0
    ;;
  "ipa-server-install")
    /lib/systemd/systemd --system
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
    chown -R www-data:www-data /var/run/ipa_memcached
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
esac

exec $@
