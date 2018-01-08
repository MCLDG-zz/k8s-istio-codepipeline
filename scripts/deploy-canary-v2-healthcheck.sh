#!/usr/bin/env bash
export PATH=$PWD/istio-0.2.10/bin:$PATH
istioctl --kubeconfig=kubeconfig.conf version
echo running health check on v2


ISTIO_INGRESS=$(./kubectl --kubeconfig=kubeconfig.conf get ingress gateway -o jsonpath="{.status.loadBalancer.ingress[0].*}")
echo load balancer endpoint
echo http://$ISTIO_INGRESS/productpage
for((i=1;i<=50;i+=1));do curl  -s http://$ISTIO_INGRESS/productpage >> mfile; done;
a=$(grep 'full stars' mfile | wc -l) && echo Number of calls to v2 of reviews service "$(($a / 2))"
rm mfile
if test $a -gt 0; then
    echo health check successful
else
    echo failing health check
    istioctl abcdefghijklmnopqrstuvwxyz
fi
