# Whoami

A simple web page to show and test if the loadbalancer is working.

After applying whoami, ``Ingress`` and ``IngressRoutes`` the following links should be reachable:

- http://whoami.localhost/
- http://whoami.localhost/foo
- http://whoami.localhost/bar
- http://foo.whoami.localhost/
- http://auth.whoami.localhost/

Note: For accessing ``auth.whoami.localhost`` you will need to login. This is because this request went over a
middleware with authentication enabled.