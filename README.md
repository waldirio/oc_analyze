# oc_analyze

## Disclaimer
This project or the binary files available in the `Releases` area are `NOT` delivered and/or released by Red Hat. This is an independent project to help customers and Red Hat Support team to analyze some data from your `OCP cluster` for reporting or troubleshooting purposes. Also, this is not changing anything, just running some queries against the `must-gather` output.

---


Basically, you can execute this script against your `must-gather`, and the same will do some queries using [`omc`](https://github.com/gmeghnag/omc) in the backend, also, we are doing some parses, and at the end of the day, a report will be created.

First, ask your customer to execute the command `oc adm must-gather`
```
# oc adm must-gather
```

In a sequence, a directory will be created, for example `must-gather.local.1238484050365797922`

You can create a tarball of this directory and send to the support. If you would like to execute this script locally on this `must-gather` directory, definitely you can
```
# wget https://raw.githubusercontent.com/QikfixAI/oc_analyze/refs/heads/master/oc_analyze.sh
# chmod +x oc_analyze.sh
# ./oc_analyze.sh
```

The output will be something as below
```
$ ./oc_analyze.sh
Please, execute as below:

./oc_analyze.sh --mgb path_to_your_regular_must-gather
or
./oc_analyze.sh --mgai path_to_your_rhoai_must-gather
or
./oc_analyze.sh --mgb path_to_your_regular_must-gather --mgai path_to_your_rhoai_must-gather
```

You can execute `oc_analyze.sh` against a regular `must-gather`, or against an `AI must-gather`. You just need to specify via flag `--mgb` or `--mgai`

Once you execute it, a new file will be created at the end of the process, and you should be able to check/analyze it.


The output will be something as below
```
$ oc_analyze.sh --mgb must-gather.local.4689572329225334722/ --mgai must-gather.local.10433306961132572/
## Must Gather Used
## Base Must-Gather
# Setting the OMC Must Gather Path
# Installed Operators
# Operator's Status
# Operator's Version (all of them)
# Operator's Subscription & Install Plan Approval
# Installation Plans
# Operator's Required by RHOAI
# Cluster Operator Status
# RHOAI Version
# Cluster and ETCd Information
# Checking All Namespaces and Pods for Pods that are NOT ok
## RHOAI Must-Gather
# Setting the OMC Must Gather Path
# Checking All Namespaces and Pods
# Checking All Namespaces and Pods for Pods that are NOT ok

## Please, check the file /tmp/oc_analyze_report_waldirio_04-24-2026_22-27-08.log for follow-up! ##
```

And a very short snippet
```
$ head /tmp/oc_analyze_report_wpinheir_04-10-2026.log -n 20

## Must Gather Used
---
Base Must-Gather ...: must-gather.local.4689572329225334722/
RHOAI Must-Gather ..: must-gather.local.10433306961132572/
---

## Base Must-Gather

# Installed Operators
---
NAME                                                              AGE
cluster-kube-descheduler-operator.openshift-kube-descheduler-op   190d
cluster-logging.openshift-logging                                 141d
cluster-observability-operator.openshift-cluster-observability    75d
devworkspace-operator.openshift-operators                         188d
fence-agents-remediation.openshift-workload-availability          190d
gpu-operator-certified.nvidia-gpu-operator                        190d
kernel-module-management.openshift-kmm                            190d
kubernetes-nmstate-operator.openshift-nmstate                     190d
...

```

Note. This is a brand new project, and I'm confident that you will find a lot of issues and improvements points, don't worry, and feel free to submit your feedback/request, they will be very welcome. Feel free to open a new issue or via email (waldirio@gmail.com | waldirio@redhat.com) or in the [Issue link](https://github.com/QikfixAI/oc_analyze/issues), on the top left of this project.
