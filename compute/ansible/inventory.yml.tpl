all:
  vars:
    ansible_user: ${ansible_user}
    ansible_ssh_private_key_file: ${ssh_private_key_path}
    ansible_ssh_common_args: >-
      -o StrictHostKeyChecking=no
      -o UserKnownHostsFile=/dev/null
      -o ControlMaster=no
      -o ControlPath=none
      -o ServerAliveInterval=30
      -o ServerAliveCountMax=3
      -o ConnectTimeout=30
      -o ProxyCommand="ssh -i ${ssh_private_key_path} -W %h:%p ${ansible_user}@${bastion_ip}"
  hosts:
    master:
      ansible_host: ${master_ip}
    node-d:
      ansible_host: ${node_d_ip}
    node-e:
      ansible_host: ${node_e_ip}
  children:
    kube_control_plane:
      hosts:
        master:
    kube_node:
      hosts:
        node-d:
        node-e:
    etcd:
      hosts:
        master:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
