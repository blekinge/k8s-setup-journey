Prometheus
------------------------
https://devopscube.com/setup-prometheus-helm-chart/

https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus


To set up Prometheus, we use Helm. First, add the Helm repository:
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```
Then, install Prometheus with the Longhorn storage class:
```
kubectl create namespace monitoring
helm install prometheus prometheus-community/prometheus \
    --namespace monitoring \
    --set alertmanager.persistence.storageClass="longhorn" \
    --set server.persistentVolume.storageClass="longhorn"
```

```
aabl@gameon:~/istio-1.26.3$ helm upgrade --install prometheus prometheus-community/prometheus \
    --namespace monitoring \
    --set alertmanager.persistence.storageClass="longhorn" \
    --set server.persistentVolume.storageClass="longhorn"
Release "prometheus" does not exist. Installing it now.
NAME: prometheus
LAST DEPLOYED: Sun Aug  3 13:53:51 2025
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.monitoring.svc.cluster.local


Get the Prometheus server URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9090


The Prometheus alertmanager can be accessed via port 9093 on the following DNS name from within your cluster:
prometheus-alertmanager.monitoring.svc.cluster.local


Get the Alertmanager URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=alertmanager,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9093
#################################################################################
######   WARNING: Pod Security Policy has been disabled by default since    #####
######            it deprecated after k8s 1.25+. use                        #####
######            (index .Values "prometheus-node-exporter" "rbac"          #####
###### .          "pspEnabled") with (index .Values                         #####
######            "prometheus-node-exporter" "rbac" "pspAnnotations")       #####
######            in case you still need it.                                #####
#################################################################################


The Prometheus PushGateway can be accessed via port 9091 on the following DNS name from within your cluster:
prometheus-prometheus-pushgateway.monitoring.svc.cluster.local


Get the PushGateway URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus-pushgateway,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9091

For more information on running Prometheus, visit:
https://prometheus.io/
aabl@gameon:~/istio-1.26.3$ 
```