# Basic Services

This folder takes care of the basic services that will run in the kubernetes cluster. As we installed in the first step
the loadbalancer and proxy Traefik. In this step we will create the IngressRoute to this. Therefor we will use the
previously deployed CRD(s).

After applying these services and ``IngressRoutes`` the services should be reachable with the following links:

- http://traefik.localhost/dashboard/#/