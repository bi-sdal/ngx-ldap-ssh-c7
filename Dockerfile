FROM dads2busy/c7-ssh-ldap
MAINTAINER "Aaron D. Schroeder" <aschroed@vt.edu>

## Install Prerequisites
RUN yum -y install php-fpm php-cli php-mcrypt php-gd php-ldap openssl mod_ssl wget pam-devel
RUN yum -y groupinstall "Development Tools"
RUN mkdir -p /tmp
COPY /nginx-1.10.3 /tmp/nginx-1.10.3
COPY /pcre-8.40 /tmp/pcre-8.40
COPY /zlib-1.2.11 /tmp/zlib-1.2.11
RUN cd /tmp/pcre-8.40 && ./configure && make && make install
RUN cd /tmp/zlib-1.2.11 && ./configure && make && make install
RUN yum -y install openssl-devel
COPY /nginx.service /lib/systemd/system
COPY /nginx-debug.service /lib/systemd/system

# Install nginx
RUN cd /tmp/nginx-1.10.3 && \
./configure \
--user=nginx                          \
--group=nginx                         \
--prefix=/etc/nginx                   \
--sbin-path=/usr/sbin/nginx           \
--conf-path=/etc/nginx/nginx.conf     \
--pid-path=/var/run/nginx.pid         \
--lock-path=/var/run/nginx.lock       \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--with-http_gzip_static_module        \
--with-http_stub_status_module        \
--with-http_ssl_module                \
--with-pcre                           \
--with-file-aio                       \
--with-http_realip_module             \
--add-module=ngx_http_auth_pam_module \
&& make && make install

RUN cp /etc/pam.d/sshd /etc/pam.d/nginx
COPY /nginx.conf /etc/nginx

RUN useradd -s /bin/false nginx

# Allow auto-creation of roles
RUN groupadd shadow
RUN chown root:shadow /etc/shadow
RUN chown root:shadow /sbin/unix_chkpwd
RUN chmod g+s /sbin/unix_chkpwd

RUN systemctl enable nginx

EXPOSE 80
EXPOSE 443

CMD ["/lib/systemd/systemd"]
