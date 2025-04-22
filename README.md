# ml-ops-kserve

This is an example demo project demonstrating the use of MiniKube, Argocd and Kserve in ML Ops processes

This project aims to:

* Setup MiniKube locally
* Boostrap the cluster with KServe resources using argoCD
* Deploy a Sklearn-iris model
* Access the model using Streamlit

<details>
<summary>MiniKube Setup</summary>

## Check Minikube is installed

To check that minikube is installed run the following command:
```shell
minkube version
```

If Minikube is installed, you will see the version number printed out, like this:
```shell
minikube version: v1.25.2
```

If the following result is returned then minikube is not installed
```shell
zsh: command not found: minikube
```

### Installing Minikube

Install Minikube with homebrew with the following command:
```shell
brew install minikube
```

## Check Minikube is running

To ensure minikube us running run the following command:
```shell
minikube status
```

If the result is as follows the minikube needs to be started:
```shell
~ % minikube status
minikube
type: Control Plane
host: Stopped
kubelet: Stopped
apiserver: Stopped
kubeconfig: Stopped
```

## Starting Minikube

To start Minikube run the commands below

```shell
minikube start --addons=dashboard
```
<details>
<summary>Add additional nodes (optional)</summary>

### Add additional nodes and labels 

```shell
minikube node add
```

Check nodes

```shell
kubectl get nodes
```

Label Nodes
```shell
kubectl label nodes minikube nodegroup=infra
kubectl label nodes minikube-1 nodegroup=application
kubectl label nodes minikube-2 nodegroup=model
```
</details>

## Stopping Minikube Cluster

```shell
minikube stop
```

## Deleting or Resetting Minikube

```shell
minikube delete
```
</details>

## KServe Helm Charts

There seems to be an authentication problem with using the KServe helms charts directly with ArgoCD and Kustomize
```shell
oci://ghcr.io/kserve/charts/kserve-crd --version v0.14.1
oci://ghcr.io/kserve/charts/kserve --version v0.14.1
```

TODO: Add details for downloading the 