#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TF_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

INVENTORY="$SCRIPT_DIR/inventory.yml"
SSH_CONFIG="$SCRIPT_DIR/ssh_config"

KUBESPRAY_DIR=${KUBESPRAY_DIR:-/srv/projects/kubespray}
KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-v2.28.0}

usage() {
  cat <<EOF
usage: $0 {generate|uptime|cluster|kubeconfig|tunnel}

  generate    собрать inventory.yml и ssh_config из terraform output
  uptime      показать команду проверки доступа к мастеру
  cluster     установить кластер через kubespray
  kubeconfig  забрать admin.conf с мастера в ~/.kube/config-final-project
  tunnel      держать туннель к API на 127.0.0.1:6443
EOF
}

require_ssh_config() {
  if [ ! -f "$SSH_CONFIG" ]; then
    echo "нет $SSH_CONFIG, сначала: $0 generate" >&2
    exit 1
  fi
}

cmd_generate() {
  local json
  json=$(terraform -chdir="$TF_DIR" output -json)

  JSON="$json" python3 - "$SCRIPT_DIR" <<'PY'
import json
import os
import sys
from string import Template

data = json.loads(os.environ["JSON"])
script_dir = sys.argv[1]


def value(name):
    return data[name]["value"]


nodes = value("node_ips")
mapping = {
    "ansible_user": value("ansible_user"),
    "ssh_private_key_path": os.path.expanduser(value("ssh_private_key_path")),
    "bastion_ip": value("bastion_ip"),
    "master_ip": value("master_ip"),
    "node_d_ip": nodes["node-d"],
    "node_e_ip": nodes["node-e"],
}

with open(os.path.join(script_dir, "inventory.yml.tpl")) as template_file:
    template = Template(template_file.read())

with open(os.path.join(script_dir, "inventory.yml"), "w") as inventory_file:
    inventory_file.write(template.substitute(mapping))
PY

  terraform -chdir="$TF_DIR" output -raw ssh_config > "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"

  echo "сгенерировано:"
  echo "  $INVENTORY"
  echo "  $SSH_CONFIG"
}

cmd_uptime() {
  require_ssh_config
  local master_ip
  master_ip=$(terraform -chdir="$TF_DIR" output -raw master_ip)
  echo "ssh -F $SSH_CONFIG $master_ip"
}

cmd_cluster() {
  require_ssh_config
  if [ ! -f "$INVENTORY" ]; then
    echo "нет $INVENTORY, сначала: $0 generate" >&2
    exit 1
  fi

  if [ ! -d "$KUBESPRAY_DIR/.git" ]; then
    git clone --branch "$KUBESPRAY_VERSION" --depth 1 \
      https://github.com/kubernetes-sigs/kubespray.git "$KUBESPRAY_DIR"
  fi

  cd "$KUBESPRAY_DIR"

  if [ ! -f .venv/bin/activate ]; then
    rm -rf .venv
    python3 -m venv .venv
  fi
  # shellcheck disable=SC1091
  source .venv/bin/activate
  pip install -q -r requirements.txt

  ansible-playbook -i "$INVENTORY" --become --become-user=root cluster.yml
}

cmd_kubeconfig() {
  require_ssh_config
  local master_ip target
  master_ip=$(terraform -chdir="$TF_DIR" output -raw master_ip)
  target="$HOME/.kube/config-final-project"

  mkdir -p "$(dirname "$target")"
  ssh -F "$SSH_CONFIG" "$master_ip" 'sudo cat /etc/kubernetes/admin.conf' > "$target"
  # мастер приватный, ходим к API через туннель
  sed -i 's#server: https://.*:6443#server: https://127.0.0.1:6443#' "$target"
  chmod 600 "$target"

  echo "KUBECONFIG=$target"
  echo "в одном терминале: bash $0 tunnel"
  echo "в другом: export KUBECONFIG=$target"
}

cmd_tunnel() {
  require_ssh_config
  local master_ip
  master_ip=$(terraform -chdir="$TF_DIR" output -raw master_ip)
  echo "туннель https://127.0.0.1:6443 → $master_ip (Ctrl+C для выхода)"
  exec ssh -F "$SSH_CONFIG" -N -L 6443:"$master_ip":6443 "$master_ip"
}

case "${1:-}" in
  generate) cmd_generate ;;
  uptime) cmd_uptime ;;
  cluster) cmd_cluster ;;
  kubeconfig) cmd_kubeconfig ;;
  tunnel) cmd_tunnel ;;
  *) usage; exit 1 ;;
esac
