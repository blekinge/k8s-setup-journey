Prometheus
------------------------
https://devopscube.com/setup-prometheus-helm-chart/

https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus


To set up Prometheus, we use Helm. First, add the Helm repository:
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```
Then, install Prometheus with the local config



```
kubectl create namespace monitoring
helm install prometheus prometheus-community/kube-prometheus-stack \ 
 --namespace monitoring  \
 -f values.yaml 
```

```
aabl@gameon:~$ helm install prometheus prometheus-community/kube-prometheus-stack  --namespace monitoring -f values.yaml 
NAME: prometheus
LAST DEPLOYED: Sun Dec  7 13:59:08 2025
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus"

Get Grafana 'admin' user password by running:

  kubectl --namespace monitoring get secrets prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

Access Grafana local instance:

  export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=prometheus" -oname)
  kubectl --namespace monitoring port-forward $POD_NAME 3000

Get your grafana admin user password by running:

  kubectl get secret --namespace monitoring -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo


Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
aabl@gameon:~$ 
```

Grafana is now available at http://prometheus-grafana.monitoring.app.k8s.askov.net/login
