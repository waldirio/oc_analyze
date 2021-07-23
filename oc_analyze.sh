#!/bin/bash

#
# Created ....: 06/25/2021
# Developer ..: Waldirio M Pinheiro <waldirio@gmail.com / waldirio@redhat.com>
# Purpose ....: Analyze the output of "oc adm must-gather" and collect some info
#


if [ "$1" == "" ]; then
  echo "you have to pass the 'oc must-gather' output dir'"
  echo "exiting now ..."
  exit
fi


base_dir=$1

quay_test_dir=$(ls -l $base_dir | grep ^d | grep quay-io-openshift | wc -l)
if [ $quay_test_dir -ne 1 ]; then
  echo "this is not a valid 'oc must-gather' dir"
  echo "exiting ..."
  exit
fi

main()
{
count=$(ls -1 $base_dir/quay*/cluster-scoped-resources/core/nodes/* | wc -l)
nodes=$(ls -1 $base_dir/quay*/cluster-scoped-resources/core/nodes/*)
general_info=$(cat $base_dir/quay*/cluster-scoped-resources/core/nodes/* | grep "^    node-role.kubernetes.io" | sort | uniq -c | sort -nr)
cluster_name=$(cat $base_dir/quay*/cluster-scoped-resources/operator.openshift.io/kubecontrollermanagers/cluster.yaml | grep -A1 cluster-name | grep -v "cluster-name" | awk '{print $2}')
cluster_id=$(cat $base_dir/quay*/cluster-scoped-resources/config.openshift.io/clusterversions.yaml | grep "^    clusterID" | awk '{print $2}')

echo "      Total # of nodes: $count"
echo
echo "$general_info"
echo
echo "Cluster Name ....: $cluster_name"
echo "Cluster ID ......: $cluster_id"
echo
echo "---"
#echo $nodes
for b in $nodes
do
  #echo - $b
  #set -x
  server_name=$(cat $b | grep "^  name:" | awk '{print $2}')
  node_role=$(cat $b | grep "^    node-role.kubernetes.io" | sed -s 's/^    //g')
  cpu=$(cat $b | grep -A1  "^  capacity:" | grep cpu | cut -d\" -f2)
  os=$(cat $b | grep "^    node.openshift.io/os_id" | awk '{print $2}')

  echo "Server name .......: $server_name"
  echo "Node role .........: $node_role"
  echo "CPU ...............: $cpu"
  echo "OS ................: $os"
  echo "---"
done
}


main
