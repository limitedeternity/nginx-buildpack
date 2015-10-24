#!/bin/bash
# Build NGINX and modules on Heroku.

NGINX_VERSION=1.9.5
PCRE_VERSION=8.37
OPENSSL_VERSION=1.0.1p

nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
pcre_tarball_url=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz
openssl_tarball_url=http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz

temp_dir=$(mktemp -d /tmp/heroku_nginx.XXXXXXXXXX)

cleanup() {
  echo "Cleaning up $temp_dir"
  cd /
  rm -rf "$temp_dir"
}
#trap cleanup EXIT

script_dir=$(cd $(dirname $0); pwd)
vulcan_archive_result=$temp_dir/nginx-${NGINX_VERSION}-built-with-vulcan.tar.gz
untarring_dir=$temp_dir/untarring
nginx_binary_drop_dir=$script_dir/../bin

cd $temp_dir
echo "Temp dir: $temp_dir"

echo "Downloading $nginx_tarball_url"
curl $nginx_tarball_url | tar xzf -

echo "Downloading $pcre_tarball_url"
(cd nginx-${NGINX_VERSION} && curl $pcre_tarball_url | tar xzf -)

echo "Building PCRE"
pwd
(cd nginx-${NGINX_VERSION}/pcre-${PCRE_VERSION} && ./configure && make)
pwd

echo "Downloading $openssl_tarball_url"
(cd nginx-${NGINX_VERSION} && curl $openssl_tarball_url | tar xzf -)

echo "Building NGINX-$NGINX_VERSION"
(cd nginx-${NGINX_VERSION} && ./configure --with-http_ssl_module --with-http_v2_module --with-openssl=openssl-${OPENSSL_VERSION} --with-pcre=pcre-${PCRE_VERSION} && make)

echo "Nginx binary can be found at $temp_dir/nginx-$NGINX_VERSION/objs/nginx"
echo "Create a git build branch, copy the nginx file, commit, and push"

