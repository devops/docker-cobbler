#!/bin/bash

cobbler_setting() {
    # password
    PASSWORD=`openssl passwd -1 -salt hLGoLIZR $ROOT_PASSWORD`
    sed -i "s#^default_password.*#default_password_crypted: \"$PASSWORD\"#g" /etc/cobbler/settings

    # tftp
    sed -i '/disable/c\\tdisable\t\t\t= no' /etc/xinetd.d/tftp

    # rsync
    sed -i -e 's/\=\ yes/\=\ no/g' /etc/xinetd.d/rsync

    # web auth
    ## setup cobbler default web username password: cobbler/cobbler
    sed -i 's/module = authn_denyall/module = authn_configfile/g' /etc/cobbler/modules.conf
    (echo -n "cobbler:Cobbler:" && echo -n "cobbler:Cobbler:$ROOT_PASSWORD" | md5sum - | cut -d' ' -f1) > /etc/cobbler/users.digest

    # dnsmasq
    if [ $DHCP_IGNORE ]
    then
        echo "dhcp-ignore=tag:!known" >> /etc/cobbler/dnsmasq.template
        echo "dhcp-ignore=#known">> /etc/cobbler/dnsmasq.template
    fi
    if [ $NO_DHCP_INTERFACE ]
    then
        echo "no-dhcp-interface=$NO_DHCP_INTERFACE" >> /etc/cobbler/dnsmasq.template
    fi
    sed -i "s/192.168.1.5,192.168.1.200/$DHCP_RANGE/" /etc/cobbler/dnsmasq.template
    sed -i "s/module = manage_bind/module = manage_dnsmasq/g" /etc/cobbler/modules.conf
    sed -i "s/module = manage_isc/module = manage_dnsmasq/g" /etc/cobbler/modules.conf

     # debmirror
    sed -i -e 's|@dists=.*|#@dists=|'  /etc/debmirror.conf
    sed -i -e 's|@arches=.*|#@arches=|'  /etc/debmirror.conf

    # auto configure
    cp /etc/cobbler/settings /etc/cobbler/settings.ori
    sed -i 's/^[[:space:]]\+/ /' /etc/cobbler/settings
    sed -i 's/allow_dynamic_settings: 0/allow_dynamic_settings: 1/g' /etc/cobbler/settings
    service cobblerd  start
    service httpd start
    cobbler setting edit --name=server --value=$SERVER_IP
    cobbler setting edit --name=pxe_just_once --value=1
    cobbler setting edit --name=next_server --value=$SERVER_IP
    cobbler setting edit --name=manage_rsync --value=1
    cobbler setting edit --name=manage_dhcp --value=1
    cobbler setting edit --name=manage_dns --value=1
}

# Configure cobbler
cobbler_setting
cobbler sync > /dev/null 2>&1

# Stop services
service httpd stop
service xinetd stop
service dnsmasq stop
service cobblerd stop

# Running services
service httpd start
service xinetd start
service dnsmasq restart
/usr/bin/cobblerd -F
