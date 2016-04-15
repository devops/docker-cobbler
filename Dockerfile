# cobbler
#
# version 0.1

FROM centos:6.7
MAINTAINER z@zstack.net

RUN yum update -y && yum --quiet install -y epel-release tftp-server xinetd cobbler cobbler-web dnsmasq pykickstart cman debmirror koan
RUN yum clean all
RUN service httpd start ; service cobblerd start ; cobbler get-loaders ; service httpd stop ; service cobblerd stop

ADD start.sh /start.sh
RUN chmod +x /start.sh

VOLUME ["/var/www/html"]
EXPOSE 53 53/udp 67 67/udp 69/udp 80 443 873
CMD ["/start.sh"]
