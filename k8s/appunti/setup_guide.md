# Setup guide

## Master Node

Install the needed prerequisite:

```Shell
 sudo apt-get install ca-certificates curl gnupg lsb-release

 sudo mkdir -p /etc/apt/keyrings

 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

 echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install docker and containerd, the runtime we're gonna use:

```Shell
 sudo apt update

 sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
 ```

Install kubelet, kubeadm and kubectl:

```Shell
 curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

 cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
 deb https://apt.kubernetes.io/ kubernetes-xenial main
 EOF

 sudo apt update

 sudo apt install kubectl kubeadm kubelet
```

Perform the `sudo kubeadm init --pod-network-cidr=192.168.0.0/16` (10.244.0.0/16 for Flannel).
If it returns an error try:

```Shell
 rm /etc/containerd/config.toml
 systemctl restart containerd
 kubeadm init
```

Then make the cluster executable:

```Shell
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Install CNI (Calico is a CNI supported by LIQO):

```Shell
 kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.4/manifests/tigera-operator.yaml

 wget https://raw.githubusercontent.com/projectcalico/calico/v3.24.4/manifests/custom-resources.yaml

 nano custom-resources.yaml
```

(or you can install WeaveNet)

```Shell

```

Patch the custom resources to adapt with LIQO:

```Yaml
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    nodeAddressAutodetectionV4:
      skipInterface: liqo.*
```

Install LIQOctl:

```Shell
 curl --fail -LS "https://github.com/liqotech/liqo/releases/download/v0.6.0/liqoctl-linux-amd64.tar.gz" | tar -xz
 sudo install -o root -g root -m 0755 liqoctl /usr/local/bin/liqoctl
```

Install Helm:

```Shell
 curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
 sudo apt-get install apt-transport-https --yes

 echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

 sudo apt-get update
 
 sudo apt-get install helm
```

Set the `strictArp` parameter to `true`:

```Shell
 kubectl edit configmap kube-proxy -n kube-system
```

Restart kube-proxy:

```Shell
 kubectl rollout restart daemonset kube-proxy -n kube-system
```

Install OpenELB as loadbalancer:

```Shell
 kubectl create -f https://raw.githubusercontent.com/openelb/openelb/master/deploy/openelb.yaml
```

Create the EIP object:

```Shell
 nano eip-object.yaml
```

```Yaml
apiVersion: network.kubesphere.io/v1alpha2
kind: Eip
metadata:
  name: layer2-eip
spec:
  address: 192.168.0.91-192.168.0.100
  interface: eth0
  protocol: layer2
```

Apply the configuration:

```Shell
 kubectl apply -f eip-object.yaml
```

Install LIQO:

```Shell
 ./liqoctl install kubeadm --cluster-name cluster-1 --verbose
 ```

### Minimum version required:
- containerd: 1.6.9
- runc:       1.1.4
- kubelet:    1.25.3
- kubeadm:    1.25.3
- kubectl:    1.25.3

## Worker node

Install CRIU:

```Shell
 echo 'deb http://download.opensuse.org/repositories/devel:/tools:/criu/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/devel:tools:criu.list

 curl -fsSL https://download.opensuse.org/repositories/devel:tools:criu/xUbuntu_20.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/devel_tools_criu.gpg > /dev/null

 sudo apt update

 sudo apt install criu
```

Install GO:

```Shell
 wget https://go.dev/dl/go1.19.3.linux-amd64.tar.gz

 sudo  rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz

 export PATH=$PATH:/usr/local/go/bin
```

Install containerd, kubeadm, kubernetes-cni and kubelet as before.

Copy the `kubeadm join`.

### Minimum version required:
- criu:       3.17.1
- go:         1.19.3


 ## Final setup
 At the end of the configuration phase, we have a setup like this:

 ![Alt text](images/setup.png)

 ## Uninstall kubernetes from a node

```Shell
 sudo kubeadm reset

 sudo apt purge kubectl kubeadm kubelet kubernetes-cni -y
 sudo apt autoremove
 sudo rm -rf .cache; sudo rm -fr /etc/kubernetes/; sudo rm -fr ~/.kube/; sudo rm -fr /var/lib/etcd; sudo rm -rf /var/lib/cni/; sudo rm -rf /opt/cni/bin;

 sudo systemctl daemon-reload

 sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

 # remove all running docker containers
 docker rm -f `docker ps -a | grep "k8s_" | awk '{print $1}'`
```


kubeadm join 172.16.5.183:6443 --token 4ioqtn.2s1wkhd8eyaxkl3f \
	--discovery-token-ca-cert-hash sha256:d6d684be923e1bdcd5ca2ac2cfbd40b6697111d1a4ce2787e8c382eba670f3a2