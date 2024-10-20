
#### MetalLB
[MetalLB](https://metallb.universe.tf/) is our Load balancer of choice.

A load-balancer handles the assignment and resolution of externally reachable IP-addresses to Kubernetes Services.

For now, we just install MetalLB with the simplest possible command
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
```

We have chosen MetalLB because it can use the [Border Gateway Protocol](https://en.wikipedia.org/wiki/Border_Gateway_Protocol) to communicate with PFSense.
See, the problem we are facing is that all external traffic is routed through PFSense. When a Load Balancer assigns an "external" IP to a service, then this IP is only external as far as the cluster is concerned. I.e. from any of the cluster nodes, you will be able to access this IP. But if we want systems that are not part of the Kubernetes cluster to resolve this IP, we need to tell PFSense that this IP is now part of the cluster.

To solve this problem, we need the Border Gateway Protocol, as this was designed exactly for routers to communicate about which IPs are reachable through which routers.


MetalLB is now installed, so it is time to configure it.
MetalLB is configured through CRDs, i.e. Custom Resource Definitions.

Here, we will follow the [official documentation](https://metallb.universe.tf/configuration/): 



### Ip Address Pool

First we must tell MetalLB which range of IP addresses it can use.
We can do this by creating an `IPAddressPool`, which  represents a pool of IP addresses that can be allocated to LoadBalancer services.

Here we define the pool `192.168.32.0/24`. It is important that we do not pick a pool that includes already included IP addresses, such as `192.168.4.0/24`, as the Load Balancer will not check if an IP address is already in use.

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: metallb-pool
  namespace: metallb-system
spec:
  addresses:
    - 192.168.32.0/24
```

### BGP Advertisement

Now we must tell MetalLB how to advertise it's allocated IPs to PFSense. We do this by creating a BGP Advertisement Custom Resource

```yaml
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
  name: metallb-advertisment
  namespace: metallb-system
spec:
  ipAddressPools:
    - metallb-pool # Reference to the IP Address Pool above
  localPref: 100 # Weight of the routes we advertise
  communities:
    - 65535:65282 # no-advertise community
```
The no-advertise community means that the peer router(s) is informed  that they can use this route, but they shouldn’t tell anyone else about it.

 
### BGP Peer

And finally, we need to configure MetalLB to send the advertisement to PFSense. We do this with a BGP Peer Custom Resource.

If you have multiple firewalls, you would need a BGP Peer CR for each firewall.

```yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
  name: metallb-bgppeer-pfsense
  namespace: metallb-system
spec:
  myASN: 64500
  peerASN: 64501
  peerAddress: 192.168.4.1 # PFSense address
```

Here you have to pick two numbers, `myASN` and `peerASN`.

ASN numbers are IDs of systems in BGP. So we pick the ID of MetalLB/The Kubernetes cluster to be `64500` and the ID of PFSense to be `64501`

PFSense
=========================

This section is heavily indepted to https://geek-cookbook.funkypenguin.co.nz/kubernetes/loadbalancer/metallb/pfsense/

First we need to install the FRR package on PFSense, as it does not come with the BGP functionality per default

![pfsense.package.frr.png](MetalLB/pfsense.package.frr.png)

### Configure FRR Global/Zebra
After the package have been installed, we must enable it (**Services -> FRR Global/Zebra**) and set our `default router id`. This must match the `peerAddress` we used in the BGP Peer CR, i.e. `192.168.4.1`

Apparently we also must set a password, but nothing will use this password. So just pick something to make the system happy.
![img.png](MetalLB/pfsense.frr.global.png)

### Configure FRR BGP

Now we must set up the Border Gateway Protocol routing (**Services -> FRR BGP**). We assign the pre-selected ASN (`64501`) as well as the Router ID
![img_1.png](MetalLB/pfsense.bgp.png)

### Configure FRR BGP Advanced
(FIXME: Why???) Then we must disable something
![img_2.png](MetalLB/pfsense.bgp.advanced1.png)

![img_3.png](MetalLB/pfsense.bgp.advanced2.png)


### BGP Neighbour
Now we must create a neighbour object for each kubernetes node. In our case, this means `k8smaster1`, `k8snode1` and `k8snode2`.

![img_5.png](MetalLB/pfsense.bgp.neighbour.png)

Each of these must be configured with the preselected MetalLB ASN (`64500`) and not much else.

