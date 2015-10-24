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
(cd nginx-${NGINX_VERSION} && ./configure --with-http_ssl_module --with-openssl=openssl-${OPENSSL_VERSION} --with-pcre=pcre-${PCRE_VERSION} && make)

#vulcan build -o ${vulcan_archive_result} -s nginx-${NGINX_VERSION} -v -p /tmp/nginx -c "./configure --with-http_ssl_module --with-openssl=openssl-${OPENSSL_VERSION} --with-pcre=pcre-${PCRE_VERSION} --prefix=/tmp/nginx && make install"

#echo "Extracting the nginx binary into the buildback"
#mkdir -p $untarring_dir
#cd $untarring_dir
#tar -xf $vulcan_archive_result
#mkdir -p $nginx_binary_drop_dir
#cp sbin/nginx $nginx_binary_drop_dir

#echo "Copied the nginx binary into $(cd $nginx_binary_drop_dir; pwd)"





#NGINX_VERSION=1.9.5
#PCRE_VERSION=8.37
#OPENSSL_VERSION=1.0.1p
#
#nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
#pcre_tarball_url=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz
#openssl_tarball_url=http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
#
#temp_dir=./build
#
#cd $temp_dir
#echo "Temp dir: $temp_dir"
#
#echo "Downloading and building $openssl_tarball_url"
#curl -OL $openssl_tarball_url
#tar -xzf openssl-${OPENSSL_VERSION}.tar.gz
#
#echo "Downloading and building $pcre_tarball_url"
#curl -OL $pcre_tarball_url
#tar -xzf pcre-${PCRE_VERSION}.tar.gz
#cd pcre-${PCRE_VERSION}
#./configure
#make
#cd ..
#
#echo "Downloading and building $nginx_tarball_url"
#curl -OL $nginx_tarball_url
#tar -xzf nginx-1.9.5.tar.gz
#cd nginx-${NGINX_VERSION}
#./configure --with-http_ssl_module --with-http_v2_module --with-pcre=../pcre-${PCRE_VERSION} --with-openssl=../openssl-${OPENSSL_VERSION}
#make
