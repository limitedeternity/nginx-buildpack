# Heroku Buildpack: NGINX

Nginx-buildpack vendors NGINX inside a dyno and connects NGINX to an app server via UNIX domain sockets. Forked from [https://github.com/ryandotsmith/nginx-buildpack](https://github.com/ryandotsmith/nginx-buildpack) with modifications also applied from [https://github.com/theoephraim/nginx-buildpack.git](https://github.com/theoephraim/nginx-buildpack.git).

## Motivation

Some application servers (e.g. Ruby's Unicorn) halt progress when dealing with network I/O. Heroku's Cedar routing stack [buffers only the headers](https://devcenter.heroku.com/articles/http-routing#request-buffering) of inbound requests. (The Cedar router will buffer the headers and body of a response up to 1MB) Thus, the Heroku router engages the dyno during the entire body transfer –from the client to dyno. For applications servers with blocking I/O, the latency per request will be degraded by the content transfer. By using NGINX in front of the application server, we can eliminate a great deal of transfer time from the application server. In addition to making request body transfers more efficient, all other I/O should be improved since the application server need only communicate with a UNIX socket on localhost. Basically, for webservers that are not designed for efficient, non-blocking I/O, we will benefit from having NGINX to handle all I/O operations.

## Versions

* Buildpack Version: 0.6
* NGINX Version: 1.13.9

## Requirements

* Your webserver listens to the socket at `/tmp/nginx.socket`.
* You touch `/tmp/app-initialized` when you are ready for traffic.
* You can start your web server with a shell command.

## Features

* Unified NXNG/App Server logs.
* [L2met](https://github.com/ryandotsmith/l2met) friendly NGINX log format.
* [Heroku request ids](https://devcenter.heroku.com/articles/http-request-id) embedded in NGINX logs.
* Crashes dyno if NGINX or App server crashes. Safety first.
* Language/App Server agnostic.
* Customizable NGINX config.
* Application coordinated dyno starts.
* Support for HTTP/2
* Support for SSL
* Uses headers_more

### Logging

NGINX will output the following style of logs:

```
measure.nginx.service=0.007 request_id=e2c79e86b3260b9c703756ec93f8a66d
```

You can correlate this id with your Heroku router logs:

```
at=info method=GET path=/ host=salty-earth-7125.herokuapp.com request_id=e2c79e86b3260b9c703756ec93f8a66d fwd="67.180.77.184" dyno=web.1 connect=1ms service=8ms status=200 bytes=21
```

### Language/App Server Agnostic

Nginx-buildpack provides a command named `bin/start-nginx` this command takes another command as an argument. You must pass your app server's startup command to `start-nginx`.

For example, to get NGINX and Unicorn up and running:

```bash
$ cat Procfile
web: bin/start-nginx bundle exec unicorn -c config/unicorn.rb
```

### Setting the Worker Processes

You can configure NGINX's `worker_processes` directive via the
`NGINX_WORKERS` environment variable.

For example, to set your `NGINX_WORKERS` to 8 on a PX dyno:

```bash
$ heroku config:set NGINX_WORKERS=8
```

### Customizable NGINX Config

You can provide your own NGINX config by creating a file named `nginx.conf.erb` in the config directory of your app. Start by copying the buildpack's [default config file](https://github.com/limitedeternity/nginx-buildpack/blob/master/config/nginx.conf.erb).

### Building NGINX for Heroku

See [scripts/build_nginx.sh](scripts/build_nginx.sh) for the build steps. Configuring is as easy as changing the "./configure" options.

To build a Heroku-compatible nginx binary, follow these steps:

1. heroku run bash --app [application]
2. mkdir build
3. cd build
4. git clone <REPO>
5. cd nginx-buildpacks/scripts
6. ./build_nginx.sh

The resulting nginx binary can be found in /tmp/heroku_nginx.XXXXXXXXXX/nginx-$NGINX_VERSION/objs/nginx where XXXXXXXXXX is system-generated and $NGINX_VERSION is the version of nginx being built.

The newly built nginx binary can be copied to /app/build/nginx-buildpack/bin/, committed, then pushed. Consider creating a git branch rather than pushing to master.

### Application/Dyno coordination

The buildpack will not start NGINX until a file has been written to `/tmp/app-initialized`. Since NGINX binds to the dyno's $PORT and since the $PORT determines if the app can receive traffic, you can delay NGINX accepting traffic until your application is ready to handle it. The examples below show how/when you should write the file when working with Unicorn.

## Setup

### Existing App

1. Update Buildpacks.

2. Update Procfile:

```
web: bin/start-nginx bundle exec unicorn -c config/unicorn.rb
```
