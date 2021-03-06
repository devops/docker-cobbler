docker run -d \
    --privileged \
    --net host \
    -p 53:53 \
    -p 53:53/udp \
    -p 67:67 \
    -p 67:67/udp \
    -p 69:69/udp \
    -p 80:80 \
    -p 443:443 \
    -p 873:873 \
    --name="cobbler6.7" \
    -v /data/docker/cobbler/html:/var/www/html \
    -e DHCP_RANGE=10.0.1.200,10.0.1.250 \
    -e SERVER_IP=10.0.1.9 \
    -e ROOT_PASSWORD=cobbler \
    -e NO_DHCP_INTERFACE=eth0 \
    cobbler:6.7
