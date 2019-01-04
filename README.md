# contrail-kubeadm
Installing Contrail on a kubeadm installed kubernetes cluster    
## Prerequisites
- Kubernetes v1.13 or later
- Kubernetes cluster installed with kubeadm
- Kubernetes node names resolvable via DNS or /etc/hosts
## Installation 
```
kubectl apply -f https://raw.githubusercontent.com/michaelhenkel/contrail-kubeadm/master/contrail.yaml
```
