#!/usr/bin/env bash
echo downloading istio
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=0.2.10 sh -
ls -l
export PATH=$PWD/istio-0.2.10/bin:$PATH
echo show istio version
istioctl --kubeconfig=kubeconfig.conf version