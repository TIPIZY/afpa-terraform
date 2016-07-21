#!/bin/sh
for ip in $(terraform output aws-ips-public) 
    do
        echo $ip
        ssh -i ~/.ssh/neoxia-ismail.pem -o "StrictHostKeyChecking no"  centos@$ip 'bash -s' < script-unitaire.sh
   done
