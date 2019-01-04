# contrail-kubeadm
Installing OpenContrail on a kubeadm installed Kubernetes cluster    
## Prerequisites
- Kubernetes v1.13 or later
- Kubernetes cluster installed with kubeadm
- Kubernetes node names resolvable via DNS or /etc/hosts
## Simple installation 
```
kubectl apply -f https://raw.githubusercontent.com/michaelhenkel/contrail-kubeadm/master/contrail.yaml
```
## Advanced installation
OpenContrail uses a profiling technique to inject configuration parameters into services.    
This allows to create cluster wide and per node configurations.    
The configmap name and label value have to match.    
### Cluster wide example
1. Create namespace
```
kubectl create namespace contrail
```
2. Create a profile config map in the namespace
```
cat << EOF > cluster.profile
KEY1=value1
KEY2=value2
EOF
kubectl create configmap cluster.profile --from-env-file=./cluster.profile -n contrail
```
3. Label ALL nodes with the profile
```
for node in `kubectl get node -o=custom-columns=NAME:.metadata.name |grep -v NAME`
do
  kubectl label node $node opencontrail.org/profile_cluster="cluster.profile"
done
```
4. Apply OpenContrail manifest
```
kubectl apply -f https://raw.githubusercontent.com/michaelhenkel/contrail-kubeadm/master/contrail.yaml
```
### Per Node example
1. Create namespace
```
kubectl create namespace contrail
```
2. Create a profile config map in the namespace
```
cat << EOF > leaf1.profile
KEY1=value1
KEY2=value2
EOF
kubectl create configmap leaf1.profile --from-env-file=./leaf1.profile -n contrail
```
3. Label only specific nodes with the profile
```
kubectl label node kvm4-eth2.local opencontrail.org/profile_leaf1=leaf1.profile
```
4. Apply OpenContrail manifest
```
kubectl apply -f https://raw.githubusercontent.com/michaelhenkel/contrail-kubeadm/master/contrail.yaml
```
### Multiple profiles example
1. Create namespace
```
kubectl create namespace contrail
```
2. Create 1st profile config map
```
cat << EOF > cluster.profile
KEY1=value1
KEY2=value2
EOF
kubectl create configmap cluster.profile --from-env-file=./cluster.profile -n contrail
```
3. Create 2nd profile config map
```
cat << EOF > leaf1.profile
KEY3=value3
KEY4=value4
EOF
kubectl label node kvm4-eth2.local opencontrail.org/profile_leaf1=leaf1.profile
```
4. Label node with both profiles
```
kubectl label node kvm4-eth2.local opencontrail.org/profile_cluster="cluster.profile"
kubectl label node kvm4-eth2.local opencontrail.org/profile_leaf1="leaf1.profile"
```
5. Apply OpenContrail manifest
```
kubectl apply -f https://raw.githubusercontent.com/michaelhenkel/contrail-kubeadm/master/contrail.yaml
```
## How it works
OpenContrail requires a set of mandatory configuration parameters in order to run    
on a Kubernetes cluster. In addition there are optional parameters which can be used   
to customize the OpenContrail installation.    
### Auto configuration of mandatory parameters
This is the list of required parameters:    
- CONTROLLER_NODES
- KUBERNETES_API_SERVER
- KUBERNETES_API_SECURE_PORT
- KUBERNETES_POD_SUBNETS
- KUBERNETES_SERVICE_SUBNETS
- KUBERNETES_CLUSTER_NAME

Each parameter is known in the Kubernetes cluster prior to the OpenContrail installation.    
Therefore each OpenContrail runs an init container as part of the daemonset which queries    
these parameters by talking to the Kubernetes API server.    
The CONTROLLER_NODES list is retrieved of the master node names.    

#### Example init container in daemonset
https://github.com/michaelhenkel/contrail-kubeadm/blob/master/contrail.yaml#L415-L419    

#### go code to talk to Kubernetes API
https://github.com/michaelhenkel/contrail-k8s-init    

### Custom configuration
In order to customize the configuration, different nodes of a Kubernetes cluster can be    
labeled with a profile. This profile points to a ConfigMap. The entrypoints of each    
OpenContrail service execute a go binary which    
1. Identfies the node the container is running on
2. Checks if the node has one or more opencontrail/profile_* labels attached
3. Checks if there is a ConfigMap which matches the label value
4. Exports the key=value pairs of the ConfigMap(s)

#### go code for profile matching
https://github.com/michaelhenkel/contrail-k8s-node-profile    
