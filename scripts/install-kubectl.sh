#!/usr/bin/env bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.7.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
ls -l
cat kubeconfig.conf
./kubectl config --kubeconfig=kubeconfig.conf view
./kubectl config --kubeconfig=kubeconfig.conf use-context cluster.k8s.local
./kubectl version --kubeconfig=kubeconfig.conf
