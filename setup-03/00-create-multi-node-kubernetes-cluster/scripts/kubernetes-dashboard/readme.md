# Install / uninstall the kubernetes dashboard

In the folder of this readme you can find the scripts to install / uninstall the dashboard. 

## Access

The easiest way is to forward the port via kubectl like: 

```
kubectl port-forward service/kubernetes-dashboard -n kubernetes-dashboard 8080:443
```

Then get the token for the login in the next step from a separate command line interface: 

```
kubectl create token admin-user -n kubernetes-dashboard
```

Copy the token and login to the dashboard at https:\\127.0.0.1:8080