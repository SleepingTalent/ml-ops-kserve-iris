#!/bin/bash
set -euo pipefail

function run_port_forward() {
  print_info "Retrieving Ingress Gateway Service..."
    INGRESS_GATEWAY_SERVICE=$(kubectl get svc --namespace istio-system --selector="app=istio-ingressgateway" --output jsonpath='{.items[0].metadata.name}')
    print_info "Ingress Gateway Service: ${INGRESS_GATEWAY_SERVICE}"

    print_info "Starting port-forwarding for Ingress Gateway Service on local port 8081 to target port 80..."
    # Start port-forwarding in the background. The PID is captured for cleanup.
    kubectl port-forward --namespace istio-system svc/"${INGRESS_GATEWAY_SERVICE}" 8081:80 &
    PORT_FORWARD_PID=$!
    print_info "Port-forward process started with PID ${PORT_FORWARD_PID}"

    # Wait a few seconds to allow port-forwarding to initialize
    sleep 5
}

function run_iris_test() {
  print_info "Retrieving the service hostname from the sklearn-iris inferenceservice..."
  SERVICE_HOSTNAME=$(kubectl get inferenceservice sklearn-iris -n sklearn-iris -o jsonpath='{.status.url}' | cut -d "/" -f 3)
  INGRESS_HOST="localhost"
  INGRESS_PORT=8081

  print_info "Service Hostname: ${SERVICE_HOSTNAME}"
  print_info "Ingress Host: ${INGRESS_HOST}"
  print_info "Ingress Port: ${INGRESS_PORT}"

  print_info "Sending prediction request..."
  curl -v -H "Host: ${SERVICE_HOSTNAME}" \
       -H "Content-Type: application/json" \
       "http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/sklearn-iris:predict" \
       -d '{
             "instances": [
               [6.8, 2.8, 4.8, 1.4],
               [6.0, 3.4, 4.5, 1.6]
             ]
           }'
  print_info "Test complete..."
#  print_info "Cleaning up port-forward process..."
#  kill ${PORT_FORWARD_PID}
#  print_info "Port-forward stopped."
}


