#!/usr/bin/env bash

#https://istio.io/latest/docs/ambient/getting-started/

# https://istio.io/latest/docs/ambient/upgrade/helm/

# Upgrade istioctl
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.29.0
export PATH=$PWD/bin:$PATH

istioctl x precheck


helm repo update istio

# Control plane

istioctl upgrade

# Base components
helm upgrade istio-base istio/base --namespace istio-system --set profile=ambient

# istiod control plane
helm upgrade istiod istio/istiod --namespace istio-system --wait  --set profile=ambient

# Control plane ends

# The Istio CNI node agent is responsible for detecting pods added to the ambient mesh, informing ztunnel that proxy ports should be established within added pods, and configuring traffic redirection within the pod network namespace. It is not part of the data plane or control plane.
helm upgrade istio-cni istio/cni --namespace istio-system  --set profile=ambient --set global.platform=k3s

# Data plane
helm upgrade ztunnel istio/ztunnel --namespace istio-system --wait  --set profile=ambient

# Upgrade manually deployed gateway chart (optional)
helm upgrade istio-ingress istio/gateway --namespace istio-ingress --set profile=ambient
