#!/usr/bin/env bash
export PATH=$PWD/istio-0.2.10/bin:$PATH
istioctl --kubeconfig=kubeconfig.conf version
echo deploying bookinfo v1
./kubectl --kubeconfig=kubeconfig.conf apply -f <(istioctl --kubeconfig=kubeconfig.conf kube-inject -f bookinfo.yaml)
echo checking the deployment
./kubectl get all --kubeconfig=kubeconfig.conf
echo route all traffic to reviews v1
./kubectl --kubeconfig=kubeconfig.conf create -f route-rule-all-v1.yaml
./kubectl --kubeconfig=kubeconfig.conf replace -f route-rule-all-v1.yaml
sleep 30
echo getting the DNS for the productpage endpoint
./kubectl --kubeconfig=kubeconfig.conf get ingress gateway -o jsonpath="{.status.loadBalancer.ingress[0].*}"
