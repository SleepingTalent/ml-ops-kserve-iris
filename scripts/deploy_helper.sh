deploy_argocd() {
  print_info "Deploying argo cd to cluster..."
  kubectl apply -k ./argocd

  check_pods_ready "argocd" "app.kubernetes.io/name=argocd-server" "argocd-server" "5s" "15"
  check_pods_ready "argocd" "app.kubernetes.io/name=argocd-applicationset-controller" "argocd-applicationset-controller" "5s" "15"
  check_pods_ready "argocd" "app.kubernetes.io/name=argocd-repo-server" "argocd-repo-server" "5s" "15"
  check_pods_ready "argocd" "app.kubernetes.io/name=argocd-application-controller" "argocd-application-controller" "5s" "15"
  check_pods_ready "argocd" "app.kubernetes.io/name=argocd-redis" "argocd-redis" "5s" "15"
}

deploy_platform() {
  print_info "Deploying platform components to cluster..."
  kubectl apply -f ./git-ops/infra/bootstrap-platform.yaml

  check_pods_ready "cert-manager" "app.kubernetes.io/instance=cert-manager" "cert-manager" "10s" "15"
  check_pods_ready "istio-system" "app=istiod" "istio" "10s" "15"
  check_pods_ready "istio-system" "app=istio-ingressgateway" "istio" "10s" "15"
  check_pods_ready "knative-serving" "app=controller" "knative" "10s" "15"
  check_pods_ready "kserve" "control-plane=kserve-controller-manager" "kserve" "10s" "15"
  print_info "All platform components are ready!"
}

remove_platform() {
  print_info "Removing platform components from cluster..."
  kubectl delete -f ./git-ops/infra/bootstrap-platform.yaml
}

deploy_models() {
  print_info "Deploying models to cluster..."
  kubectl apply -f ./git-ops/model/bootstrap-models.yaml

  check_pods_ready "sklearn-iris" "app.kubernetes.io/instance=sklearn-iris" "sklearn-iris" "20s" "20"
}

remove_models() {
  print_info "Removing models from cluster..."
  kubectl delete -f ./git-ops/model/bootstrap-models.yaml
}

deploy_apps() {
  print_info "Deploying apps to cluster..."
  kubectl apply -f ./git-ops/app/bootstrap-apps.yaml

  check_pods_ready "sklearn-iris-predictor" "app=streamlit-iris" "sklearn-iris-predictor" "10s" "15"

  print_info "Exposing streamlit-iris-service..."
  minikube service streamlit-iris-service -n sklearn-iris-predictor &
}

remove_apps() {
  print_info "Removing apps from cluster..."
  kubectl delete -f ./git-ops/app/bootstrap-apps.yaml
}

check_pods_ready() {
    local ns=$1
    local label=$2
    local component_name=$3

    TIMEOUT=$4  # Timeout per attempt
    RETRIES=$5  # Max retries
    COUNT=0

    # Record the start time
    START_TIME=$(date +%s)

    while [[ $COUNT -lt $RETRIES ]]; do

       if kubectl wait --for=condition=Ready pod -l "$label" -n "$ns" --timeout=$TIMEOUT 2>/dev/null; then
                  END_TIME=$(date +%s)
                  TOTAL_TIME=$((END_TIME - START_TIME))
                  print_info "✅ $component_name is ready! (Waited ${TOTAL_TIME}s)"
                  return 0
       fi
      COUNT=$((COUNT + 1))
      print_warning "⏳ Waiting for $component_name... Attempt $COUNT/$RETRIES"
      sleep 5
    done

    # If max retries reached, print failure message
    END_TIME=$(date +%s)
    TOTAL_TIME=$((END_TIME - START_TIME))
    print_error "⚠️ $component_name did not become ready after ${TOTAL_TIME}s and $RETRIES attempts."

    return 1
}