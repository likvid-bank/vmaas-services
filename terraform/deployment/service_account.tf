resource "kubernetes_service_account" "unipipe_vmaas" {
  metadata {
    name      = "unipipe-vmaas"
    namespace = kubernetes_namespace.unipipe_vmaas.metadata[0].name
  }

  automount_service_account_token = true
}


resource "kubernetes_role" "unipipe_vmaas" {
  metadata {
    name      = "unipipe-vmaas"
    namespace = kubernetes_namespace.unipipe_vmaas.metadata[0].name
  }

  rule {
    api_groups = ["*"]
    resources  = ["secrets"]
    verbs      = ["get", "update", "patch", "list", "write", "watch", "create"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["get", "list", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "name" {
  metadata {
    name      = "unipipe-vmaas"
    namespace = kubernetes_namespace.unipipe_vmaas.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.unipipe_vmaas.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "unipipe-vmaas"
    namespace = kubernetes_namespace.unipipe_vmaas.metadata[0].name
  }
}
