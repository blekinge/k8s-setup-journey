# Setting up Grafana dashboards for Istio

To do this, we need a [Prometheus data source](../../Prometheus.md)

Then, we can set up a simple Grafana system like
```
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.27/samples/addons/grafana.yam
```

```
helm repo add grafana https://grafana.github.io/helm-charts

helm install istio-grafana grafana/grafana \
  --namespace monitoring
```


Then get the admin password with

```
kubectl get secret --namespace istio-system grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
