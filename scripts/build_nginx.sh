#!/bin/bash
#
# Requires 'vulcan' to be installed and a build server created.
# https://devcenter.heroku.com/articles/buildpack-binaries
# This file modified from fork: https://github.com/theoephraim/nginx-buildpack.git

NGINX_VERSION=1.9.5
PCRE_VERSION=8.33
OPENSSL_VERSION=1.0.1p

nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
# pcre_tarball_url=http://garr.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.bz2
pcre_tarball_url=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz
openssl_tarball_url=http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz

temp_dir=$(mktemp -d /tmp/vulcan_nginx.XXXXXXXXXX)

cleanup() {
  echo "Cleaning up $temp_dir"
  cd /
  rm -rf "$temp_dir"
}
trap cleanup EXIT

script_dir=$(cd $(dirname $0); pwd)
vulcan_archive_result=$temp_dir/nginx-${NGINX_VERSION}-built-with-vulcan.tar.gz
untarring_dir=$temp_dir/untarring
nginx_binary_drop_dir=$script_dir/../bin

cd $temp_dir
echo "Temp dir: $temp_dir"

echo "Downloading $nginx_tarball_url"
curl $nginx_tarball_url | tar xzf -

echo "Downloading $pcre_tarball_url"
(cd nginx-${NGINX_VERSION} && curl -OL $pcre_tarball_url | tar xzf -)

echo "Downloading $openssl_tarball_url"
(cd nginx-${NGINX_VERSION} && curl $openssl_tarball_url | tar xzf -)

vulcan build -o ${vulcan_archive_result} -s nginx-${NGINX_VERSION} -v -p /tmp/nginx -c "./configure --with-http_ssl_module --with-http_v2_module --with-openssl=openssl-${OPENSSL_VERSION} --with-pcre=pcre-${PCRE_VERSION} --prefix=/tmp/nginx && make install"

echo "Extracting the nginx binary into the buildback"
mkdir -p $untarring_dir
cd $untarring_dir
tar -xzf $vulcan_archive_result
mkdir -p $nginx_binary_drop_dir
cp sbin/nginx $nginx_binary_drop_dir

echo "Copied the nginx binary into $(cd $nginx_binary_drop_dir; pwd)"