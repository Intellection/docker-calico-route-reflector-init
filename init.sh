#!/bin/sh

set -e

: ${KUBERNETES_NODE_NAME:?"You need to set the KUBERNETES_NODE_NAME environment variable."}
: ${CALICO_ROUTE_REFLECTOR_CLUSTER_ID:?"You need to set the CALICO_ROUTE_REFLECTOR_CLUSTER_ID environment variable."}
: ${CALICO_ROUTE_REFLECTOR_LABEL_NAME:?"You need to set the CALICO_ROUTE_REFLECTOR_LABEL_NAME environment variable."}

echo "Labelling node \"${KUBERNETES_NODE_NAME}\" with route reflector label..."
kubectl label node --overwrite "${KUBERNETES_NODE_NAME}" "${CALICO_ROUTE_REFLECTOR_LABEL_NAME}=${CALICO_ROUTE_REFLECTOR_LABEL_VALUE}"

echo "Annotating node \"${KUBERNETES_NODE_NAME}\" with route reflector cluster identifier..."
kubectl annotate node --overwrite "${KUBERNETES_NODE_NAME}" "projectcalico.org/RouteReflectorClusterID=${CALICO_ROUTE_REFLECTOR_CLUSTER_ID}"
