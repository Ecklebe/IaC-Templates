# Basic Services

This folder takes care of the basic services that will run in the kubernetes cluster. As we installed in the first step
the loadbalancer and proxy Traefik. In this step we will create the IngressRoute to this. Therefor we will use the
previously deployed CRD(s).

After applying these services and ``IngressRoutes`` the services should be reachable with the following links:

- http://traefik.localhost/dashboard/#/
- http://registry.localhost/v2/_catalog
- http://grafana.localhost/
- http://prometheus.localhost/
- http://alertmanager.localhost/
- http://jaeger.localhost/

## For the traefik dashboard

For the login you can use the following account:

- username = traefik-admin
- password = traefik~2022

## For the grafana dashboard

For the login you can use the following account:

- username = admin
- password = grafana~2022

## For the docker registry to work

### Adjust the hosts file

For the docker daemon to resolve the hosts file needs to be extended with a entry that is pointing
to ``registry.localhost``. On Windows the host file is located in ``C:\Windows\System32\drivers\etc\hosts``.

### Adjust the docker daemon config

To allow a push to a docker registry with a self-signed certificate the docker daemon config needs to be modified with
the additional parameter ``insecure-registries`` like in the example below:

```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "debug": true,
  "insecure-registries": [
    "registry.localhost"
  ],
  "experimental": false,
  "features": {
    "buildkit": true
  }
}
```

### Test the connection to the docker registry

```console
docker pull traefik/whoami
docker tag traefik/whoami registry.localhost/traefik/whoami
docker push registry.localhost/traefik/whoami
```

## For the prometheus dashboard

Some example searches:

````aidl
max(rate(traefik_service_requests_total[1m])) by (service)
````

````aidl
max(rate(traefik_service_requests_total[1m])) by (exported_service)
````

````aidl
(
    max(irate(traefik_service_request_duration_seconds_sum[1m])) by (exported_service)
 /  max(irate(traefik_service_request_duration_seconds_count[1m])) by (exported_service)
) * 1000
````