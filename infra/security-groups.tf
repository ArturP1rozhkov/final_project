# infra/security-groups.tf

# --- 1. Группы безопасности ---

resource "yandex_vpc_security_group" "bastion" {
  name        = "bastion"
  description = "Bastion host"
  network_id  = yandex_vpc_network.this.id
}

resource "yandex_vpc_security_group" "k8s" {
  name        = "k8s"
  description = "Kubernetes master and nodes"
  network_id  = yandex_vpc_network.this.id
}

resource "yandex_vpc_security_group" "alb" {
  name        = "final-project-alb"
  description = "Application load balancer"
  network_id  = yandex_vpc_network.this.id
}

# --- 2. Правила бастиона ---

resource "yandex_vpc_security_group_rule" "bastion_ssh" {
  security_group_binding = yandex_vpc_security_group.bastion.id
  direction              = "ingress"
  description            = "SSH from admin"
  protocol               = "TCP"
  port                   = 22
  v4_cidr_blocks         = [var.admin_cidr]
}

resource "yandex_vpc_security_group_rule" "bastion_egress" {
  security_group_binding = yandex_vpc_security_group.bastion.id
  direction              = "egress"
  description            = "All outbound"
  protocol               = "ANY"
  v4_cidr_blocks         = ["0.0.0.0/0"]
}

# --- 3. Правила кластера ---

# ssh только с бастиона
resource "yandex_vpc_security_group_rule" "k8s_ssh" {
  security_group_binding = yandex_vpc_security_group.k8s.id
  direction              = "ingress"
  description            = "SSH from bastion"
  protocol               = "TCP"
  port                   = 22
  security_group_id      = yandex_vpc_security_group.bastion.id
}

# доступ к API с бастиона
resource "yandex_vpc_security_group_rule" "k8s_api_bastion" {
  security_group_binding = yandex_vpc_security_group.k8s.id
  direction              = "ingress"
  description            = "Kubernetes API from bastion"
  protocol               = "TCP"
  port                   = 6443
  security_group_id      = yandex_vpc_security_group.bastion.id
}

# доступ к API внутри кластера
resource "yandex_vpc_security_group_rule" "k8s_api_self" {
  security_group_binding = yandex_vpc_security_group.k8s.id
  direction              = "ingress"
  description            = "Kubernetes API inside cluster"
  protocol               = "TCP"
  port                   = 6443
  predefined_target      = "self_security_group"
}

# pod-to-pod, etcd, kubelet и прочий служебный трафик
resource "yandex_vpc_security_group_rule" "k8s_self" {
  security_group_binding = yandex_vpc_security_group.k8s.id
  direction              = "ingress"
  description            = "Traffic inside cluster"
  protocol               = "ANY"
  predefined_target      = "self_security_group"
}

# ALB ходит к целям со своих адресов, поэтому источник - его группа безопасности
resource "yandex_vpc_security_group_rule" "k8s_app_nodeport" {
  security_group_binding = yandex_vpc_security_group.k8s.id
  direction              = "ingress"
  description            = "ALB to app NodePort"
  protocol               = "TCP"
  port                   = 30080
  security_group_id      = yandex_vpc_security_group.alb.id
}

resource "yandex_vpc_security_group_rule" "k8s_grafana_nodeport" {
  security_group_binding = yandex_vpc_security_group.k8s.id
  direction              = "ingress"
  description            = "ALB to grafana NodePort"
  protocol               = "TCP"
  port                   = 30081
  security_group_id      = yandex_vpc_security_group.alb.id
}

resource "yandex_vpc_security_group_rule" "k8s_egress" {
  security_group_binding = yandex_vpc_security_group.k8s.id
  direction              = "egress"
  description            = "All outbound"
  protocol               = "ANY"
  v4_cidr_blocks         = ["0.0.0.0/0"]
}

# --- 4. Правила балансировщика ---

resource "yandex_vpc_security_group_rule" "alb_ingress" {
  security_group_binding = yandex_vpc_security_group.alb.id
  direction              = "ingress"
  description            = "Public HTTP"
  protocol               = "TCP"
  port                   = 80
  v4_cidr_blocks         = ["0.0.0.0/0"]
}

resource "yandex_vpc_security_group_rule" "alb_egress" {
  security_group_binding = yandex_vpc_security_group.alb.id
  direction              = "egress"
  description            = "All outbound"
  protocol               = "ANY"
  v4_cidr_blocks         = ["0.0.0.0/0"]
}
