#!/bin/bash
certLocation=/etc/kubernetes/pki/apiserver.crt
daysToCheckBeforeExpire=10
endTime=`echo "$daysToCheckBeforeExpire*86400" | bc`

if openssl x509 -checkend $endTime -noout -in $certLocation
	then
		echo "Certificate is valid for $daysToCheckBeforeExpire days."
  else
		echo "Certificate will expire in $daysToCheckBeforeExpire days."
		cd /etc/kubernetes/pki/
		mkdir -p ~/k8s-back-`date +"%d-%m-%Y"`/pki
		mv {apiserver.crt,apiserver-etcd-client.key,apiserver-kubelet-client.crt,front-proxy-ca.crt,front-proxy-client.crt,front-proxy-client.key,front-proxy-ca.key,apiserver-kubelet-client.key,apiserver.key,apiserver-etcd-client.crt} ~/k8s-back-`date +"%d-%m-%Y"`/pki
		IP=`hostname -I | awk '{print $1}'`
		kubeadm init phase certs all --apiserver-advertise-address $IP
		cd /etc/kubernetes/
		mv {admin.conf,controller-manager.conf,kubelet.conf,scheduler.conf} ~/k8s-back-`date +"%d-%m-%Y"`
		kubeadm init phase kubeconfig all
		cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
		reboot
fi
