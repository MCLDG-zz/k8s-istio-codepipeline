#!/usr/bin/env bash
export PATH=$PWD/istio-0.2.10/bin:$PATH
istioctl --kubeconfig=kubeconfig.conf version
echo running health check on v3


ISTIO_INGRESS=$(./kubectl --kubeconfig=kubeconfig.conf get ingress gateway -o jsonpath="{.status.loadBalancer.ingress[0].*}")
for((i=1;i<=50;i+=1));do curl  -s http://$ISTIO_INGRESS/productpage >> mfile; done;
a=$(grep 'full stars' mfile | wc -l) && echo Number of calls to v3 of reviews service "$(($a / 2))"
rm mfile
echo failing health check - rolling back
./kubectl --kubeconfig=kubeconfig.conf replace -f route-rule-reviews-all-v2.yaml
istioctl abcdefghijklmnopqrstuvwxyz