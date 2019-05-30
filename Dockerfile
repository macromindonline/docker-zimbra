#################################################################
# Dockerfile to build Zimbra Collaboration 8.8.7 container images
# Based on Ubuntu 16.04
# Created by Jorge de la Cruz
#################################################################
FROM ubuntu:16.04
MAINTAINER Jorge de la Cruz <jorgedlcruz@gmail.com>

RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
  wget \
  dialog \
  openssh-client \
  software-properties-common \
  dnsmasq \
  dnsutils \
  net-tools \
  sudo \
  rsyslog \
  unzip
  
RUN groupadd -g 999 zimbra && groupadd -g 998 postfix && groupadd -g 113 clamav

RUN useradd -s /bin/bash -d /opt/zimbra -p $(date +%s|sha256sum|base64|head -c 32) -u 999 -g zimbra zimbra

RUN usermod -a -G adm zimbra && usermod -a -G tty zimbra && usermod -a -G postfix zimbra

RUN useradd -s /bin/false -d /opt/zimbra/postfix -g postfix postfix

RUN useradd -s /bin/false -d /var/lib/clamav -g clamav clamav

VOLUME ["/opt/zimbra"]

EXPOSE 22 25 465 587 110 143 993 995 80 443 8080 8443 7071

COPY opt /opt/

COPY etc /etc/

CMD ["/bin/bash", "/opt/start.sh", "-d"]
