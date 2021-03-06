# Cluster Basics

This folder takes care of the basic setup for kubernetes. Basic custom resource definitions (CRD) are applied to extend
the kubernetes api and to use the extension later to setup applications or use defined kind's to set ingress routes with
Traefik.

## Extend Kubernetes

There are different ways to apply CRD(s) and to extend so the kubernetes cluster:

- The first way would be applying them with ``kubectl apply -f some.yml``
- The second way is using the terraform named resource ``kubernetes_manifest``
  . This is also the reason why we need this pre-setup step here.

## Installed Applications

With the basic cluster setup come some applications that are in the following described in some more details. Now
shortly the urls as list to access them later:

- http://cluster.local/dashboard/#/
- http://registry.cluster.local/v2/_catalog
- http://grafana.cluster.local/
- http://prometheus.cluster.local/
- http://alertmanager.cluster.local/
- http://cluster.local/jaeger

### Installed User Account

User:     tobias

Password: cluster-development-2022

### Traefik

#### Dashboard

If Traefik is installed the dashboard is not reachable until the ingress route is applied. To access in such situation
the dashboard to check if everything works normal the next command can be executed.

```
kubectl port-forward service/traefik-dashboard -n kube-system 9000:9000
```

The dashboard should be then reachable with: ``http://127.0.0.1:9000/dashboard``

After the ingress route is applied the dashboard will be reachable under:
http://cluster.local/dashboard/#/ with the credentials shown at installed user account.

#### Metrics

Similar as the dashboard the metrics endpoint can be reach after applying the next command
at: http://127.0.0.1:9100/metrics

````
kubectl port-forward service/traefik-metrics -n kube-system 9100:9100
````

### Alertmanager

kubectl port-forward service/prometheus-kube-prometheus-alertmanager -n default 9093:9093
http://127.0.0.1:9093

### Grafana

For the login you can use the following account:

- username = admin
- password = grafana~2022

### Prometheus

#### For the prometheus dashboard

Some example searches:

````
max(rate(traefik_service_requests_total[1m])) by (service)
````

````
max(rate(traefik_service_requests_total[1m])) by (exported_service)
````

````
(
    max(irate(traefik_service_request_duration_seconds_sum[1m])) by (exported_service)
 /  max(irate(traefik_service_request_duration_seconds_count[1m])) by (exported_service)
) * 1000
````

### Docker Registry

#### For the docker registry to work

##### Adjust the hosts file

For the docker daemon to resolve the hosts file needs to be extended with a entry that is pointing
to ``registry.cluster.local``. On Windows the host file is located in ``C:\Windows\System32\drivers\etc\hosts``.

##### Adjust the docker daemon config

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
    "registry.cluster.local"
  ],
  "experimental": false,
  "features": {
    "buildkit": true
  }
}
```

##### Test the connection to the docker registry

```console
docker pull traefik/whoami
docker tag traefik/whoami registry.cluster.local/traefik/whoami
docker push registry.cluster.local/traefik/whoami

docker tag traefik/whoami cluster.local/registry/traefik/whoami
docker push cluster.local/registry/traefik/whoami
```

##### Debug the docker registry

````
wsl 
````

##### Docker registry commands

https://docs.docker.com/registry/spec/api/#detail

````
https://cluster.local/registry/v2/traefik/whoami/tags/list

https://cluster.local/registry/v2/traefik/whoami/manifests/latest
````