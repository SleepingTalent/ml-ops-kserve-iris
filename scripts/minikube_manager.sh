#!/bin/bash
#source ./output_helper.sh

minikube_manager() {
  # Ensure a command argument is provided
  if [ -z "$1" ]; then
     print_error "Usage: $0 {status|start|stop|reset}"
         exit 1
  fi

  # Perform the requested minikube operation
  case "$1" in
      status)
              print_info "Minikube status..."
              minikube status
              ;;
      start)
          print_info "Starting Minikube..."
          minikube start
          print_info "Setting kubectl context to Minikube..."
          kubectl config use-context minikube
          print_warning "Current kubectl context: $(kubectl config current-context)"
          print_info "Minikube started..."
          ;;
      stop)
          print_info "Stopping Minikube..."
          minikube stop
          print_info "Minikube stopped..."
          ;;
      reset)
          print_info "Resetting Minikube..."
          minikube delete
          minikube start
          print_info "Minikube started..."
          ;;
      *)
          print_error "Invalid command: $1"
          usage
          ;;
  esac
}
