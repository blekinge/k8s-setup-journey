Istio
------------------------------------


## Download the Istio CLI
Istio is configured using a command line tool called istioctl. Download it, and the Istio sample applications:

```
$ curl -L https://istio.io/downloadIstio | sh -
$ cd istio-1.26.3
$ export PATH=$PWD/bin:$PATH
```
Check that you are able to run istioctl by printing the version of the command. At this point, Istio is not installed in your cluster, so you will see that there are no pods ready.

```
$ istioctl version
Istio is not present in the cluster: no running Istio pods in namespace "istio-system"
client version: 1.26.3
```


## Setup Istio


https://istio.io/latest/docs/ambient/getting-started/

```
aabl@gameon:~/istio-1.26.3$ istioctl install --set profile=ambient --set values.global.platform=k3s
        |\          
        | \         
        |  \        
        |   \       
      /||    \      
     / ||     \     
    /  ||      \    
   /   ||       \   
  /    ||        \  
 /     ||         \ 
/______||__________\
____________________
  \__       _____/  
     \_____/        

This will install the Istio 1.26.3 profile "ambient" into the cluster. Proceed? (y/N) y
✔ Istio core installed ⛵️                                                                                                                                                                                                         
✔ Istiod installed 🧠                                                                                                                                                                                                              
✔ CNI installed 🪢                                                                                                                                                                                                                 
✔ Ztunnel installed 🔒                                                                                                                                                                                                             
✔ Installation complete                                                                                                                                                                                                            
The ambient profile has been installed successfully, enjoy Istio without sidecars!
aabl@gameon:~/istio-1.26.3$ 


```


```
aabl@gameon:~/istio-1.26.3$ kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
aabl@gameon:~/istio-1.26.3$ 

```


## Sample app Bookinfo


https://istio.io/latest/docs/ambient/getting-started/deploy-sample-app/


```
aabl@gameon:~/istio-1.26.3$ kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml 
service/details created
serviceaccount/bookinfo-details created
deployment.apps/details-v1 created
service/ratings created
serviceaccount/bookinfo-ratings created
deployment.apps/ratings-v1 created
service/reviews created
serviceaccount/bookinfo-reviews created
deployment.apps/reviews-v1 created
deployment.apps/reviews-v2 created
deployment.apps/reviews-v3 created
service/productpage created
serviceaccount/bookinfo-productpage created
deployment.apps/productpage-v1 created
aabl@gameon:~/istio-1.26.3$
```
```
aabl@gameon:~/istio-1.26.3$ kubectl apply -f samples/bookinfo/platform/kube/bookinfo-versions.yaml 
service/reviews-v1 created
service/reviews-v2 created
service/reviews-v3 created
service/productpage-v1 created
service/ratings-v1 created
service/details-v1 created
aabl@gameon:~/istio-1.26.3$
```
```
aabl@gameon:~/istio-1.26.3$ kubectl get pods
NAME                                      READY   STATUS    RESTARTS      AGE
coredns-697968c856-t7ggd                  1/1     Running   6 (16m ago)   35d
details-v1-766844796b-t8rrg               1/1     Running   0             17s
local-path-provisioner-774c6665dc-rc8m9   1/1     Running   6 (16m ago)   35d
metrics-server-6f4c6675d5-f6wjg           1/1     Running   6 (16m ago)   35d
productpage-v1-54bb874995-668dk           1/1     Running   0             14s
ratings-v1-5dc79b6bcd-bz748               1/1     Running   0             17s
reviews-v1-598b896c9d-q9k2b               1/1     Running   0             15s
reviews-v2-556d6457d-f5kcr                1/1     Running   0             15s
reviews-v3-564544b4d6-4sc2h               1/1     Running   0             15s
traefik-c98fdf6fb-bsgw5                   1/1     Running   6 (16m ago)   35d
aabl@gameon:~/istio-1.26.3$ 


```



### Deploy and configure the ingress gateway
You will use the Kubernetes Gateway API to deploy a gateway called bookinfo-gateway:

```
$ kubectl apply -f samples/bookinfo/gateway-api/bookinfo-gateway.yaml
```

To check the status of the gateway, run:
```
aabl@gameon:~/istio-1.26.3$ kubectl get gateway -A
NAMESPACE     NAME               CLASS   ADDRESS        PROGRAMMED   AGE
default   bookinfo-gateway   istio   192.168.32.5   True         5m25s
aabl@gameon:~/istio-1.26.3$ 
```
Wait for the gateway to show as programmed before continuing.

You can now access the application on the url http://bookinfo-gateway-istio.default.app.k8s.askov.net/productpage

If you refresh the page, you should see the display of the book ratings changing as the requests are distributed across the different versions of the reviews service.



### Add Bookinfo to the mesh
You can enable all pods in a given namespace to be part of an ambient mesh by simply labeling the namespace:

```
aabl@gameon:~/istio-1.26.3$ kubectl label namespace default istio.io/dataplane-mode=ambient
namespace/default labeled
aabl@gameon:~/istio-1.26.3$ 
```
Congratulations! You have successfully added all pods in the default namespace to the ambient mesh. 🎉

If you open the Bookinfo application in your browser, you will see the product page, just like before. The difference this time is that the communication between the Bookinfo application pods is encrypted using mTLS. Additionally, Istio is gathering TCP telemetry for all traffic between the pods.

You now have mTLS encryption between all your pods — without even restarting or redeploying any of the applications!

## Visualize the application and metrics

To visualize, we need Prometheus and Kiali deployed to your cluster.


See the [Prometheus](Prometheus.md) and [Kiali](Kiali.md) sections for more information.

You can access the Kiali dashboard by running the following command:
```
$ istioctl dashboard kiali
```
Let’s send some traffic to the Bookinfo application, so Kiali generates the traffic graph:
```
aabl@gameon:~/istio-1.26.3$ for i in $(seq 1 100); do curl -sSI -o /dev/null http://bookinfo-gateway-istio.default.app.k8s.askov.net/productpage; done
aabl@gameon:~/istio-1.26.3$ 

```
Next, click on the Traffic Graph and select “Default” from the “Select Namespaces” drop-down. You should see the Bookinfo application:

http://localhost:20001/kiali/console/graph/namespaces/?traffic=ambient%2CambientTotal%2Cgrpc%2CgrpcRequest%2Chttp%2ChttpRequest%2Ctcp%2CtcpSent&graphType=versionedApp&duration=600&refresh=60000&layout=dagre&namespaces=default
![img.png](img.png)





 Enforce Layer 4 authorization policy
---------------------------------

Let’s create an authorization policy that restricts which services can communicate with the productpage service. The policy is applied to pods with the app: productpage label, and it allows calls only from the the service account cluster.local/ns/default/sa/bookinfo-gateway-istio. This is the service account that is used by the Bookinfo gateway you deployed in the previous step.

```
$ kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: productpage-ztunnel
  namespace: default
spec:
  selector:
    matchLabels:
      app: productpage
  action: ALLOW
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/default/sa/bookinfo-gateway-istio
EOF
```
If you open the Bookinfo application in your browser (http://localhost:8080/productpage), you will see the product page, just as before. However, if you try to access the productpage service from a different service account, you should see an error.

Let’s try accessing Bookinfo application from a different client in the cluster: