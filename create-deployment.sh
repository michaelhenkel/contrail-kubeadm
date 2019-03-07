#!/bin/bash

replicas=1
output="./contrail.yaml"
outputFile="./"
while getopts r:o:h option
do
  case "${option}"
  in
    r) replicas=${OPTARG};;
    o) output=${OPTARG};;
    h) help=true;;
  esac
done

if [[ -n $help ]]; then
  echo "Usage: ./create-deployment.sh OPTIONS"
  echo "  OPTIONS:"
  echo "    -r number of replicas (uneven number, default 1)"
  echo "    -o output path and filename (default ./contrail.yaml)"
  exit 0
fi

helm template -n contrail --namespace contrail --set global.replicas=$replicas --output-dir /tmp/ helm/Contrail/
cat /tmp//Contrail/templates/contrail-namespace.yaml > $output
cat /tmp//Contrail/templates/contrail-config-map.yaml >> $output
cat /tmp//Contrail/templates/contrail-rbac.yaml >> $output
cat /tmp//Contrail/charts/cassandra/templates/cassandra.yaml >> $output
cat /tmp//Contrail/charts/rabbitmq/templates/rabbitmq.yaml >> $output
cat /tmp//Contrail/charts/zookeeper/templates/zookeeper.yaml >> $output
cat /tmp//Contrail/charts/redis/templates/redis.yaml >> $output
cat /tmp//Contrail/charts/config/templates/config.yaml >> $output
cat /tmp//Contrail/charts/analytics/templates/analytics.yaml >> $output
cat /tmp//Contrail/charts/control/templates/control.yaml >> $output
cat /tmp//Contrail/charts/webui/templates/webui.yaml >> $output
cat /tmp//Contrail/charts/kubemanager/templates/kubemanager.yaml >> $output
cat /tmp//Contrail/charts/vrouter/templates/vrouter.yaml >> $output
echo "################################################"
echo "    created $output"               
echo " execute with \"kubectl apply -f $output\""
echo "################################################"
