#!/bin/bash

#
# Created ....: 06/25/2021
# Developer ..: Waldirio M Pinheiro <waldirio@gmail.com / waldirio@redhat.com>
# Purpose ....: Analyze the output of "oc adm must-gather" and collect some info
#

base_dir=""
must_gather_base_dir=""
must_gather_rhoai_dir=""
type_mg=""
base_mg=false
rhoai_mg=false
OMC="/tmp/script/omc"
fmt="%-50s %-45s %-25s\n" 
TEMP_FILE="/tmp/temp_file.$$"
OUTPUT="/tmp/oc_analyze_report_${USER}_$(date +'%m-%d-%Y').log"
> $OUTPUT

check_requirements()
{
  #OMC="/tmp/script/omc"
  temporary_omc_path=$(which omc)

  # Checking if there is an OMC binary in your path. In case of yes, let's use it.
  if [ $? -eq 0 ]; then
    OMC=$temporary_omc_path
  else
    if [ ! -f $OMC ]; then
      echo "No omc available - $OMC"
      echo "exiting now ..."
      exit
    fi
  fi
}

check_must-gather()
{
  count=$(echo $@ | wc -w)
  #echo "Count: $count"
  if [ "$1" == "" ] || [ $count -ne 2 ] && [ $count -ne 4 ]; then
    echo "Please, execute as below:"
    echo
    echo "$0 --mgb path_to_your_regular_must-gather"
    echo "or"
    echo "$0 --mgai path_to_your_rhoai_must-gather"
    echo "or"
    echo "$0 --mgb path_to_your_regular_must-gather --mgai path_to_your_rhoai_must-gather"
    echo "or"
    echo "$0 --mgai path_to_your_rhoai_must-gather --mgb path_to_your_regular_must-gather"
    #echo "exiting now ..."
    exit
  else
    if [ "$1" == "--mgb" ] && [ -d $2 ] && [ "$3" == "--mgai" ] && [ -d $4 ] && [ $count -eq 4 ]; then
      #echo "parameters ok and dir for --mgb and --mgai are valid"
      #echo "dir for --mgai is valid"
      must_gather_base_dir=$2
      must_gather_rhoai_dir=$4

      quay_test_dir=$(ls -l $must_gather_base_dir | grep ^d | grep quay-io-openshift | wc -l)
      rhoai_test_dir=$(ls -l $must_gather_rhoai_dir | grep ^d | grep registry-redhat-io-rhoai-odh | wc -l)
      
      if [ $quay_test_dir -ne 1 ]; then
        echo "this is not a valid 'QUAY oc must-gather' dir"
        echo "exiting ..."
        exit
      else
        #echo "valid for base"
        type_mg="base"
        base_mg=true
      fi

      if [ $rhoai_test_dir -ne 1 ]; then
        echo "this is not a valid 'RHOAI oc must-gather' dir"
        echo "exiting ..."
        exit
      else
        #echo "valid for rhoai"
        type_mg="rhoai"
        rhoai_mg=true
      fi


    elif [ "$1" == "--mgai" ] && [ -d $2 ] && [ "$3" == "--mgb" ] && [ -d $4 ] && [ $count -eq 4 ]; then
      #echo "parameters ok and dir for --mgb and --mgai are valid"
      #echo "dir for --mgai is valid"
      must_gather_rhoai_dir=$2
      must_gather_base_dir=$4

      quay_test_dir=$(ls -l $must_gather_base_dir | grep ^d | grep quay-io-openshift | wc -l)
      rhoai_test_dir=$(ls -l $must_gather_rhoai_dir | grep ^d | grep registry-redhat-io-rhoai-odh | wc -l)
      
      if [ $quay_test_dir -ne 1 ]; then
        echo "this is not a valid 'QUAY oc must-gather' dir"
        echo "exiting ..."
        exit
      else
        #echo "valid for base"
        type_mg="base"
        base_mg=true
      fi

      if [ $rhoai_test_dir -ne 1 ]; then
        echo "this is not a valid 'RHOAI oc must-gather' dir"
        echo "exiting ..."
        exit
      else
        #echo "valid for rhoai"
        type_mg="rhoai"
        rhoai_mg=true
      fi


    elif [ "$1" == "--mgb" ] && [ -d $2 ] && [ $count -eq 2 ]; then
      #echo "parameters ok and dir for --mgb is valid"
      #echo "dir for --mgb is valid"
      must_gather_base_dir=$2

      quay_test_dir=$(ls -l $must_gather_base_dir | grep ^d | grep quay-io-openshift | wc -l)
      #rhoai_test_dir=$(ls -l $must_gather_rhoai_dir | grep ^d | grep registry-redhat-io-rhoai-odh | wc -l)
      
      if [ $quay_test_dir -ne 1 ]; then
        echo "this is not a valid 'QUAY oc must-gather' dir"
        echo "exiting ..."
        exit
      else
        #echo "valid for base"
        type_mg="base"
        base_mg=true
      fi

    elif [ "$1" == "--mgai" ] && [ -d $2 ] && [ $count -eq 2 ]; then
      #echo "parameters ok and dir for --mgai is valid"
      #echo "dir for --mgai is valid"
      must_gather_rhoai_dir=$2

      rhoai_test_dir=$(ls -l $must_gather_rhoai_dir | grep ^d | grep registry-redhat-io-rhoai-odh | wc -l)
      
      if [ $rhoai_test_dir -ne 1 ]; then
        echo "this is not a valid 'RHOAI oc must-gather' dir"
        echo "exiting ..."
        exit
      else
        #echo "valid for rhoai"
        type_mg="rhoai"
        rhoai_mg=true
      fi
    else
      echo "parameters wrong and/or dir for --mgb and --mgai are missing"
      echo "exiting now ..."
      exit
    fi

  fi
}

div_function()
{
#  echo "########" >> $OUTPUT
  echo >> $OUTPUT
}

set_folder_omc_mg()
{
  $OMC use $1 &>/dev/null

  if [ $? -ne 0 ]; then
    echo "Something went wrong setting the must-gather folder on OMC"
  else
    #echo "omc dir set properly"
    echo "# Setting the OMC Must Gather Path" | tee -a $OUTPUT
    echo "---" >> $OUTPUT
    echo "Path ..: $1" >> $OUTPUT
    echo "---" >> $OUTPUT

    div_function
  fi

}

installed_additional_operators()
{
  echo "# Installed Operators" | tee -a $OUTPUT
  echo "---" >> $OUTPUT
  $OMC get operators >> $OUTPUT
  echo "---" >> $OUTPUT

  div_function
}

additional_operator_status()
{
  echo "# Operator's Status" | tee -a $OUTPUT
  echo "---" >> $OUTPUT
  $OMC get ClusterServiceVersion >> $OUTPUT
  echo "---" >> $OUTPUT
  div_function
}

additional_operator_versions()
{
  echo "# Operator's Version (all of them)" | tee -a $OUTPUT
  echo "---" >> $OUTPUT
  printf "$fmt" "NAME" "VERSION" >> $OUTPUT
  $OMC get csv -A --no-headers | awk '{print $2}' | sort -u | sed 's/\./ /' | while read operator_name version
  do
    #printf "$fmt" $b "NOT_INSTALLED" "NOT_INSTALLED"
    printf "$fmt" ${operator_name}.${version} $version >> $OUTPUT
  done
  echo "---" >> $OUTPUT
  div_function
}

additional_operator_install_plan_approval()
{
  echo "# Operator's Install Plan Approval" | tee -a $OUTPUT
  echo "---" >> $OUTPUT
  $OMC get csv -A --no-headers >$TEMP_FILE

  printf "$fmt" "OPERATOR" "NAMESPACE" "INSTALL_PLAN_VALUE" >> $OUTPUT
  #$OMC get csv -A --no-headers | awk '{print $2}' | sort -u | while read operator
  cat $TEMP_FILE | awk '{print $2}' | sort -u | while read operator
  do
    #echo - $operator
    just_operator=$(echo $operator | sed 's/\./ /' | awk '{print $1}')
    count=$(grep "$operator" $TEMP_FILE | awk '{print $1}' | sort -u | wc -l)
    if [ $count -eq 1 ]; then
      namespace=$(grep "$operator" $TEMP_FILE | awk '{print $1}')
    else
      namespace="openshift-operators"
    fi

    install_plan_value=$(grep "^  installPlanApproval" $base_dir/*/namespaces/$namespace/operators.coreos.com/subscriptions/$just_operator*.yaml 2>/dev/null | awk '{print $2}')

    printf "$fmt" $operator $namespace $install_plan_value >> $OUTPUT
  done

  echo "---" >> $OUTPUT
  echo "Note. If you see **openshift-operators** as namespace, probably this operator has visibility in multiple namespaces" >> $OUTPUT
  echo "Note. If the InstallPlanValue is empty, probably the file is missing in the must-gather" >> $OUTPUT
  div_function
  rm -rf $TEMP_FILE
}

additional_operator_required_by_rhoai()
{
  echo "# Operator's Required by RHOAI" | tee -a $OUTPUT
  echo "---" >> $OUTPUT
  echo "---" >> $OUTPUT
  div_function
}

cluster_status()
{
  echo "# Cluster Operator Status" | tee -a $OUTPUT
  echo "---" >> $OUTPUT
  # Checking if there is any cluster operator that is degraded
  validate_degraded_cluster=$($OMC get co --no-headers | awk '$5 == "True"' | wc -l)

  if [ $validate_degraded_cluster -eq 0 ]; then
    echo "All OK" >> $OUTPUT
  else
    printf "$fmt" "OPERATOR" "VERSION" "DEGRADED" >> $OUTPUT
    printf "$fmt" "--------" "-------" "--------" >> $OUTPUT

    $OMC get co --no-headers | awk '$5 == "True"' | while read -r name ver avail prog deg since
    do
      printf "$fmt" "$name" "$ver" "$deg" >> $OUTPUT
    done
  fi
  echo "---" >> $OUTPUT
  div_function
}

rhoai_version()
{
  echo "# RHOAI Version" | tee -a $OUTPUT
  echo "---" >> $OUTPUT
  printf "$fmt" "NAME" "VERSION" >> $OUTPUT
  $OMC get csv -A --no-headers | awk '{print $2}' | sort -u | sed 's/\./ /' | grep rhods-operator | while read operator_name version
  do
    #printf "$fmt" $b "NOT_INSTALLED" "NOT_INSTALLED"
    printf "$fmt" ${operator_name}.${version} $version >> $OUTPUT
  done
  echo "---" >> $OUTPUT
  div_function
}

present_mg()
{
  echo "## Must Gather Used" | tee -a $OUTPUT
  echo "---" >> $OUTPUT
  echo "Base Must-Gather ...: $must_gather_base_dir" >> $OUTPUT
  echo "RHOAI Must-Gather ..: $must_gather_rhoai_dir" >> $OUTPUT
  echo "---" >> $OUTPUT
  div_function
}

check_all_namespaces_pods()
{
  echo "# Checking All Namespaces and Pods" | tee -a $OUTPUT
  echo "---" >> $OUTPUT
  for ns in $($OMC get namespaces --no-headers | awk '{print $1}')
  do 
    echo "Namespace: $ns" >> $OUTPUT
    $OMC get pods -n $ns &>> $OUTPUT
    echo >> $OUTPUT
  done
  echo "---" >> $OUTPUT
  div_function
}

cluster_etcd_info()
{
  echo "# Cluster and ETCd Information" | tee -a $OUTPUT
  echo "---" >> $OUTPUT
  $OMC get nodes>> $OUTPUT
  echo >> $OUTPUT
  $OMC etcd members>> $OUTPUT
  echo >> $OUTPUT
  $OMC etcd health>> $OUTPUT
  echo >> $OUTPUT
  $OMC etcd status>> $OUTPUT
  echo "---" >> $OUTPUT
  div_function
}

# Main calls here
check_requirements
check_must-gather $@
div_function
present_mg

if $base_mg; then
  echo "## Base Must-Gather" | tee -a $OUTPUT
  echo >> $OUTPUT

  set_folder_omc_mg $must_gather_base_dir
  
  installed_additional_operators
  additional_operator_status
  additional_operator_versions
  additional_operator_install_plan_approval
  additional_operator_required_by_rhoai
  cluster_status
  rhoai_version
  cluster_etcd_info
fi

if $rhoai_mg; then
  echo "## RHOAI Must-Gather" | tee -a $OUTPUT
  echo >> $OUTPUT

  set_folder_omc_mg $must_gather_rhoai_dir

  check_all_namespaces_pods
fi

echo
echo "## Please, check the file $OUTPUT for follow-up! ##"
