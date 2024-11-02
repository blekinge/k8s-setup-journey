DNS server for LoadBalancer IPs
======================================


Proposed setup:

1. CoreDNS in Kubernetes
   * It hosts a DNS server, and is updated as kubernetes change state
   * MetalLB LoadBalancer external IP (192.168.32.x/24) for CoreDNS
2. Domain Override in PFSense Dns Forwarder
    * https://docs.netgate.com/pfsense/en/latest/services/dns/forwarder-overrides.html#domain-overrides
    * Forward all *.k8s.askov.net requests to CoreDNS in Kubernetes
    * CoreDNS will respond with the LoadBalancer IP of the service


https://www.reddit.com/r/homelab/comments/ipsc4r/howto_k8s_metallb_and_external_dns_access_for/?rdt=40382