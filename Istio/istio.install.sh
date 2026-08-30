#!/usr/bin/env bash

# https://istio.io/latest/docs/ambient/install/helm/

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update


# Base components
helm install istio-base istio/base -n istio-system --create-namespace --set profile=ambient --wait

# Install or upgrade the Kubernetes Gateway API CRDs
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml

# istiod control plane
# The istiod chart installs a revision of Istiod. Istiod is the control plane component that manages and configures the proxies to route traffic within the mesh.

helm install istiod istio/istiod --namespace istio-system --set profile=ambient --wait

#CNI node agent
# The cni chart installs the Istio CNI node agent. It is responsible for detecting the pods that belong to the ambient mesh, and configuring the traffic redirection between pods and the ztunnel node proxy (which will be installed later).

helm install istio-cni istio/cni -n istio-system --set profile=ambient --set global.platform=k3s --wait

#Install the data plane

# ztunnel DaemonSet
#  The ztunnel chart installs the ztunnel DaemonSet, which is the node proxy component of Istio’s ambient mode.

helm install ztunnel istio/ztunnel -n istio-system --wait

# Ingress gateway (optional)
# Istio supports the Kubernetes Gateway API and intends to make it the default API for traffic management in the future. If you use the Gateway API, you do not need to install and manage an ingress gateway Helm chart as described below. Refer to the Gateway API task for details.

helm install istio-ingress istio/gateway -n istio-ingress --create-namespace --wait

