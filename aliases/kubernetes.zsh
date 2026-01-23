# ========================================
# Kubernetes
# ========================================
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kgd="kubectl get deployments"
alias kgn="kubectl get nodes"
alias kga="kubectl get all"
alias kl="kubectl logs -f"
alias kx="kubectl exec -it"
alias kctx="kubectl config use-context"
alias kns="kubectl config set-context --current --namespace"
alias kdesc="kubectl describe"
alias kapply="kubectl apply -f"
alias kdelete="kubectl delete -f"

# 便利なKubernetes関数
# 現在のコンテキストとネームスペースを表示
kinfo() {
  echo "Context: $(kubectl config current-context)"
  echo "Namespace: $(kubectl config view --minify -o jsonpath='{..namespace}')"
}

# Pod名をfzfで選択してログを表示
klogs() {
  local pod
  pod=$(kubectl get pods -o name | fzf --preview 'kubectl logs {} --tail=50')
  [ -n "$pod" ] && kubectl logs -f "$pod"
}

# Pod名をfzfで選択してexec
kexec() {
  local pod
  pod=$(kubectl get pods -o name | fzf --preview 'kubectl describe {}')
  [ -n "$pod" ] && kubectl exec -it "$pod" -- /bin/sh
}
