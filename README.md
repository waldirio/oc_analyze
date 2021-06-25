# oc_analyze

This script will help you to collect some information from your OCP cluster, basically, we are looking for
- Server Name
- Node Role
- CPU
- OS

First, ask your customer to execute the command `oc adm must-gather`
```
# oc adm must-gather
```

In a sequence, a directory will be created, for example `must-gather.local.1238484050365797922`

You can create a tarball of this directory and send to the support. If you would like to execute this script on this dir, definitely you can
```
# ./oc_analyze.sh must-gather.local.1238484050365797922
```

The output will be something as below
```
$ ./oc_analyze.sh must-gather.local.953723949960813177/
      Total # of nodes: 6

      4     node-role.kubernetes.io/master: ""
      1     node-role.kubernetes.io/worker: ""
      1     node-role.kubernetes.io/infra: ""

Cluster Name ....: myocpcluster
Cluster ID ......: 6a1266e7-73e1-4392-9a5e-3b59b5540db7

---
Server name .......: master-0.ocp.local.domain
Node role .........: node-role.kubernetes.io/master: ""
CPU ...............: 4
OS ................: rhcos
---
Server name .......: master-1.ocp.local.domain
Node role .........: node-role.kubernetes.io/master: ""
CPU ...............: 4
OS ................: rhcos
---
Server name .......: master-2.ocp.local.domain
Node role .........: node-role.kubernetes.io/master: ""
CPU ...............: 4
OS ................: rhcos
---
Server name .......: worker-0.ocp.local.domain
Node role .........: node-role.kubernetes.io/master: ""
CPU ...............: 4
OS ................: rhcos
---
Server name .......: worker-1.ocp.local.domain
Node role .........: node-role.kubernetes.io/worker: ""
CPU ...............: 4
OS ................: rhcos
---
Server name .......: worker-2.ocp.local.domain
Node role .........: node-role.kubernetes.io/infra: ""
CPU ...............: 4
OS ................: rhcos
---
```

I hope you enjoy it, any feedback/request will be very welcome. Feel free to open a new issue or via email (waldirio@gmail.com | waldirio@redhat.com)