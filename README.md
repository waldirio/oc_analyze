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

```

I hope you enjoy it, any feedback/request will be very welcome. Feel free to open a new issue or via email (waldirio@gmail.com | waldirio@redhat.com)