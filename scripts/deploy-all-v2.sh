#!/usr/bin/env bash
export PATH=$PWD/istio-0.2.10/bin:$PATH
istioctl --kubeconfig=kubeconfig.conf version
echo deploying bookinfo v2
./kubectl --kubeconfig=kubeconfig.conf replace -f route-rule-reviews-all-v2.yaml
