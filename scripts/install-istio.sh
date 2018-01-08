#!/usr/bin/env bash
./kubectl apply -f istio-0.2.10/install/kubernetes/istio.yaml --kubeconfig=kubeconfig.conf
./kubectl get all --namespace istio-system --kubeconfig=kubeconfig.conf