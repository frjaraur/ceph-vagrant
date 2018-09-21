#!/bin/bash
#
ADMIN=$1
shift
HOSTS=$*

HOSTNAME=$(hostname)

if [ "${HOSTNAME}" = "${ADMINNODE}" ] 
then

	set -e
	yes "/root/.ssh/id_rsa" | sudo ssh-keygen -t rsa -N ""
	for host in ${HOSTS}; do
		sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo mkdir -p /root/.ssh"
		sudo cat /root/.ssh/id_rsa.pub | \
        	sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo tee /root/.ssh/authorized_keys"
	done
	#cd /vagrant
	#sudo ansible-playbook site.yaml
fi

touch /tmp_deploying_stage/${HOSTNAME}.provisioned
