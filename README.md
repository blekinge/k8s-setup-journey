My K8S Setup Journey
================================================

A Guide to how I set up my Kubernetes cluster. This guide was made to serve as backing for an upcoming podcast/stream.

Episodes
---------------
* [X] [PFSense network setup](/PFSense%20K8S%20Network.md) 
* [X] [VM setup](VMs.md)
* [X] [K3s](K3s.md)
* [ ] Networking
  * [X] [MetalLB and PFSense](MetalLB.md)
  * [X] [DNS resolution for PFSense](DNS.md)
  * [X] [Istio](Istio.md)
  * [ ] [Cert Manager](CertManager.md)
  * [ ] [Traefik](Traefik.md)
* [X] [Longhorn (storage)](Longhorn.md)
* [ ] Monitoring
  * [X] [Kubernetes Dashboard](Dashboard.md)
  * [X] [Kiali](Kiali.md)
  * [X] [Prometheus](Prometheus.md)
  * [ ] [Grafana](Grafana.md)


# URLS

https://pfsense.askov.net/services_wol.php

https://kubernetes-dashboard.kubernetes-dashboard.app.k8s.askov.net
Retrieve token with
```
kubectl get secret kubernetes-dashboard-serviceaccount-secret -n kubernetes-dashboard -o jsonpath="{.data.token}" | base64 -d
```

http://longhorn-ui.longhorn-system.app.k8s.askov.net


```
istioctl dashboard kiali
istioctl dashboard grafana
istioctl dashboard prometheus
```