# Test applications

## Whoami

A simple web page to show and test if the loadbalancer is working.

After applying whoami, ``Ingress`` and ``IngressRoutes`` the following links should be reachable:

- http://whoami.localhost/
- http://whoami.localhost/foo
- http://whoami.localhost/bar
- http://foo.whoami.localhost/
- http://auth.whoami.localhost/

Note: For accessing ``auth.whoami.localhost`` you will need to login. This is because this request went over a
middleware with authentication enabled.

## httpbin

A simple web page to show and test if the loadbalancer is working.

After applying whoami, ``IngressRoutes`` and the following link should be reachable:

- http://httpbin.localhost/

### Test with cURL

From Linux shell or WSL

````
curl -I http://localhost:80/  -H "host:httpbin.localhost"
````

### Use with apache benchmarking tool

#### Prerequisites

The tool ``ab`` accessible locally.

Help: https://httpd.apache.org/docs/2.4/programs/ab.html

#### Usage

From Linux shell or WSL

````
ab -c 5 -n 10000  -m PATCH -H "host:httpbin.localhost" -H "accept: application/json" http://localhost:80/patch
ab -c 5 -n 10000  -m GET -H "host:httpbin.localhost" -H "accept: application/json" http://localhost:80/get
ab -c 5 -n 10000  -m POST -H "host:httpbin.localhost" -H "accept: application/json" http://localhost:80/post
````
