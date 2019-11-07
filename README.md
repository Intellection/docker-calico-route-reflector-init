# Calico Route Reflector Init

[![CircleCI](https://circleci.com/gh/Intellection/docker-calico-route-reflector-init/tree/master.svg?style=svg)](https://circleci.com/gh/Intellection/docker-calico-route-reflector-init/tree/master)

An [init container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) that configures a Kubernetes node to act as a Calico [BGP route reflector](https://docs.projectcalico.org/v3.9/networking/routereflector#content-main).

## Overview

The container performs two tasks that automates the configuration of a node for route reflection:

1. Applies a [label](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) to the node which should be used in [`BGPPeer`](https://docs.projectcalico.org/v3.9/reference/resources/bgppeer#bgp-peer-definition) resources to indicate which nodes should (or should not) peer with this node.
2. Applies an [annotation](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) to the node specifying a cluster identifier, indicating that this node is a route reflector.


## Usage

This should be used as an [init container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) for the `calico-node` daemonset that will be acting as both a `calico-node` and a route reflector, thus we recommend two sepearate daemonsets of `calico-node`: 
* One that  targets nodes intended to be route reflectors (i.e. masters).
* One that targets the rest of the nodes (i.e. workers).

### Example

In this example, we're configuring the masters to be our route reflectors.

```yaml
kind: DaemonSet
apiVersion: apps/v1
metadata:
  name: calico-node-master
  namespace: kube-system
spec:
  ...
  template:
    ...
    spec:
      ...
      nodeSelector:
        # Run calico-node-master on masters only.
        node-role.kubernetes.io/master: ""
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule
      initContainers:
        - name: configure-route-reflector
          image: zappi/calico-route-reflector-init:0.1.0
          env:
            # Use the Downward API set the node name.
            - name: KUBERNETES_NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
            - name: CALICO_ROUTE_REFLECTOR_LABEL_NAME
              value: "calico-route-reflector"
            - name: CALICO_ROUTE_REFLECTOR_CLUSTER_ID
              value: "1.1.1.1"
```

Since our masters are already running their own `calico-node`, we must ensure that our second daemonset only runs on worker nodes.

```yaml
kind: DaemonSet
apiVersion: apps/v1
metadata:
  name: calico-node
  namespace: kube-system
  ...
spec:
  ...
  template:
    ...
    spec:
      ...
      nodeSelector:
        # Run calico-node on workers only.
        node-role.kubernetes.io/node: ""
```



## Environment Variables

| Name                                 | Description                                                                  | Example                        | Required |
| -------------------------------------| -----------------------------------------------------------------------------| -------------------------------|----------|
| `KUBERNETES_NODE_NAME`               | The name of the node to be labelled and annotated.                           | `ip-10-24-101-78.ec2.internal` | Yes      |
| `CALICO_ROUTE_REFLECTOR_LABEL_NAME`  | The name of the label to be used for peering configuration.                  | `calico-route-reflector`       | Yes      |
| `CALICO_ROUTE_REFLECTOR_LABEL_VALUE` | The value of the label to be used for peering configuration.                 | `true`                         | No       |
| `CALICO_ROUTE_REFLECTOR_CLUSTER_ID`  | The cluster identifier to use when annotating the node as a route reflector. | `224.0.0.1`                    | Yes      |


## Compatibility

We should be able to support Calico [3.3.0](https://docs.projectcalico.org/v3.3/releases/#v330) and later.
