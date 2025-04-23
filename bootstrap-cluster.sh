#!/bin/bash
source ./scripts/output_helper.sh
source ./scripts/deploy_helper.sh
source ./scripts/minikube_manager.sh
source ./scripts/test_helper.sh

if [ -z "$1" ]; then
     print_error "Usage: $0 {start_platform|stop|deploy_models|remove_models|deploy_apps|remove_apps}"
     exit 1
  fi

  case "$1" in
      start_platform)
          start_time=$(date +%s)
          print_info "Starting Bootstrap..."
          minikube_manager reset
          minikube_manager status
          print_info "Deploying platform..."

          deploy_argocd
          print_info "Exposing argocd..."
          minikube service argocd-server -n argocd &
          print_info "ArgoCD username:admin password:admin"

          deploy_platform
          end_time=$(date +%s)
          elapsed=$(( end_time - start_time ))
          print_info "Bootstrap completed in ${elapsed} seconds"
          ;;
      stop)
          minikube_manager stop
          minikube_manager status
          ;;
      remove_models)
          print_info "Removing models..."
          remove_models
          ;;
      deploy_models)
          print_info "Deploying models..."
          deploy_models
          ;;
      test_models)
          print_info "Testing model..."
          run_port_forward
          run_iris_test
          ;;
      deploy_apps)
          print_info "Deploying app..."
          deploy_apps
          ;;
      remove_apps)
          print_info "Remove app..."
          remove_apps
          ;;
      *)
          print_error "Invalid command: $1"
          exit 1
          ;;
  esac
