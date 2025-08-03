Kiali
--------------------------------
To install Kiali, we can simply use the Kiali operator, which can be installed with Helm.
https://kiali.io/docs/installation/installation-guide/install-with-helm/
Add the helm repos
```
helm repo add kiali https://kiali.org/helm-charts
helm repo update
```

And then install the operator
```
helm install \
    --set cr.create=true \
    --set cr.namespace=istio-system \
    --set cr.spec.auth.strategy="anonymous" \
    --namespace kiali-operator \
    --create-namespace \
    kiali-operator \
    kiali/kiali-operator
```

Note, this does not actually create an instance of Kiali, but rather the operator that will create it for us. We need to create a Kiali instance ourselves, which we can do by creating this resource
```yaml
apiVersion: "kiali.io/v1alpha1"
kind: "Kiali"
metadata:
  finalizers:
  - "kiali.io/finalizer"
  name: "kiali"
  namespace: "istio-system"
spec:
  auth:
    strategy: "anonymous"
  deployment:
    cluster_wide_access: true
  external_services:
    prometheus:
      url: "http://prometheus-server.monitoring:80"
```

```
kubectl apply -f Istio/istio-kiali-specs.yaml
```
