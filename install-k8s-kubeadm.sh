host=`hostname`
kubeversion="1.17.8-00"



echo "Get the Docker gpg - Press Enter to Continue"
read x
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo "Add the Docker Repository - Press Enter to continue"
read x
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"



echo "Get the kubernetes key - Press Enter to Continue"
read x
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -


echo "Add the kubernetes repository - Press Enter to Continue"
read x
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

echo "Update the packages - Press Enter to Continue"
read x
sudo apt-get update


echo "Install Docker,kubelet,kubeadm and kubectl - Press Enter to Continue"
sudo apt-get install -y docker-ce=5:19.03.12~3-0~ubuntu-bionic kubelet=$kubeversion kubeadm=$kubeversion kubectl=$kubeversion


echo "Hold the kubernetes binaries at the kubeverion-"$kubeversion "- Press Enter to Continue"
read x
sudo apt-mark hold docker-ce kubelet kubeadm kubectl


echo "Add IP table rule to sysctl.conf - Press Enter to Continue"
read x
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf

echo "Enable IP tables immediately - Press Enter to Continue"
read x
sudo sysctl -p


if [ "$host" = "sammyboyle1c.mylabserver.com" ]; 
then 
sudo kubeadm init --pod-network-cidr=10.244.0.0/16  > init.cmd
chmod +x init.cmd
#scp init.cmd cloud_user@sammyboyle2c.mylabserver.com
#scp init.cmd cloud_user@sammyboyle3c.mylabserver.com

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml


fi
