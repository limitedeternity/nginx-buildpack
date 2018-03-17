#!/bin/bash
# Build NGINX and modules on Heroku.

NGINX_VERSION=1.13.9
PCRE_VERSION=8.38
HEADERS_MORE_VERSION=0.33
OPENSSL_VERSION=1.1.0g

nginx_tarball_url=https://nginx.ru/download/nginx-${NGINX_VERSION}.tar.gz
headers_more_url=https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz
openssl_tarball_url=https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
pcre_tarball_url=https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz

echo "Downloading $nginx_tarball_url"
curl $nginx_tarball_url | tar xzf -

echo "Downloading $headers_more_url"
(cd nginx-${NGINX_VERSION} && curl -L $headers_more_url | tar xzf -)

echo "Downloading $pcre_tarball_url" 
(cd nginx-${NGINX_VERSION} && curl $pcre_tarball_url | tar xzf -)

echo "Building PCRE"
(cd nginx-${NGINX_VERSION}/pcre-${PCRE_VERSION} && ./configure && make)

echo "Downloading $openssl_tarball_url"
(cd nginx-${NGINX_VERSION} && curl $openssl_tarball_url | tar xzf -)

echo "Building NGINX-$NGINX_VERSION"
(cd nginx-${NGINX_VERSION} && ./configure --with-http_ssl_module --with-http_v2_module --with-openssl=openssl-${OPENSSL_VERSION} --with-pcre=pcre-${PCRE_VERSION} --add-module=headers-more-nginx-module-${HEADERS_MORE_VERSION} && make)

echo "Nginx binary can be found at /nginx-$NGINX_VERSION/objs/nginx"
echo "Create a git build branch, copy the nginx file, commit, and push"
