#!/usr/bin/env bash

_MY_SCRIPT="${BASH_SOURCE[0]}"
_MY_DIR=$(cd "$(dirname "$_MY_SCRIPT")" && pwd)
# Avoids 1.7.x because of https://github.com/kubernetes/minikube/issues/2240
_KUBERNETES_VERSION=v1.9.4
_MINIKUBE_VERSION=v0.25.2
_HELM_VERSION=v2.8.1
_VM_DRIVER=none

_UNAME_OUT=$(uname -s)
case "${_UNAME_OUT}" in
    Linux*)     _MY_OS=linux;;
    Darwin*)    _MY_OS=darwin;;
    *)          _MY_OS="UNKNOWN:${unameOut}"
esac
echo "Local OS is ${_MY_OS}"

export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export CHANGE_MINIKUBE_NONE_USER=true

rm -rf tmp
mkdir -p bin tmp
if [[ ! -x bin/kubectl ]]; then
  echo Downloading kubectl, which is a requirement for using minikube.
  curl -Lo bin/kubectl  \
    https://storage.googleapis.com/kubernetes-release/release/${_KUBERNETES_VERSION}/bin/${_MY_OS}/amd64/kubectl
  chmod +x bin/kubectl
fi
if [[ ! -x bin/minikube ]]; then
  echo Downloading minikube.
  curl -Lo bin/minikube  \
    https://storage.googleapis.com/minikube/releases/${_MINIKUBE_VERSION}/minikube-${_MY_OS}-amd64
  chmod +x bin/minikube
fi
if [[ ! -x bin/helm ]]; then
  echo Downloading helm
  curl -Lo tmp/helm.tar.gz  \
    https://storage.googleapis.com/kubernetes-helm/helm-${_HELM_VERSION}-${_MY_OS}-amd64.tar.gz
  (cd tmp; tar xfz helm.tar.gz; mv ${_MY_OS}-amd64/helm ${_MY_DIR}/bin)
fi

export PATH="${_MY_DIR}/bin:$PATH"


_MINIKUBE="sudo PATH=$PATH bin/minikube"

$_MINIKUBE config set bootstrapper localkube
$_MINIKUBE start --kubernetes-version=${_KUBERNETES_VERSION}  ${_VM_DRIVER:-}
$_MINIKUBE update-context