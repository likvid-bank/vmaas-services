terraform {
  backend "gcs" {
    bucket = "meshcloud-tf-states"
    prefix = "meshcloud-demo/unipipe-vmaas"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "gke_meshcloud-meshcloud--bc0_europe-west1_meshstacks-ha"
}


variable "arm_client_secret" {
  type      = string
  sensitive = true
}

resource "kubernetes_namespace" "unipipe_vmaas" {
  metadata {
    name = "unipipe-vmaas-likvid"
  }
}

locals {
  labels = {
    "app.kubernetes.io/name" = "unipipe-vmaas"
  }
}

resource "tls_private_key" "git_ssh_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "random_password" "basic_auth_password" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "unipipe_vmaas" {
  metadata {
    name      = "unipipe-vmaas-config"
    namespace = kubernetes_namespace.unipipe_vmaas.metadata[0].name
  }

  data = {
    "GIT_REMOTE"              = "git@github.com:likvid-bank/vmaas-services.git"
    "GIT_REMOTE_BRANCH"       = "main"
    "GIT_SSH_KEY"             = tls_private_key.git_ssh_key.private_key_pem
    "APP_BASIC_AUTH_USERNAME" = "marketplace"
    "APP_BASIC_AUTH_PASSWORD" = random_password.basic_auth_password.result
  }
}

resource "kubernetes_secret" "unipipe_vmaas_tf" {
  metadata {
    name      = "unipipe-vmaas-tf-config"
    namespace = kubernetes_namespace.unipipe_vmaas.metadata[0].name
  }

  data = {
    "ARM_CLIENT_SECRET"      = var.arm_client_secret
    "GIT_USER_EMAIL"         = "unipipe-terraform@meshcloud.io"
    "GIT_USER_NAME"          = "UniPipe"
    "ARM_SUBSCRIPTION_ID"    = "e1c85eff-0a2c-4268-9b6c-7d2ff9ca9848"
    "ARM_CLIENT_ID"          = "ac50274b-bb0a-4e74-9f42-6c4d8de388c6"
    "ARM_TENANT_ID"          = "703c8d27-13e0-4836-8b2e-8390c588cf80"
    "KUBE_IN_CLUSTER_CONFIG" = "true"
    "TF_VAR_platform_secret" = "unused"
    "TF_IN_AUTOMATION"       = "true"
  }
}


resource "kubernetes_service" "meshfed" {
  metadata {
    name      = "unipipe-vmaas"
    namespace = kubernetes_namespace.unipipe_vmaas.metadata[0].name
    labels    = local.labels
  }

  spec {
    type     = "ClusterIP"
    selector = local.labels

    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }
  }
}

resource "kubernetes_deployment" "unipipe_vmaas" {
  metadata {
    name      = "unipipe-vmaas"
    namespace = kubernetes_namespace.unipipe_vmaas.metadata[0].name
    labels    = local.labels
  }

  spec {
    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        name   = "unipipe-vmaas"
        labels = local.labels
      }

      spec {
        service_account_name = kubernetes_service_account.unipipe_vmaas.metadata[0].name

        container {
          name  = "unipipe-service-broker"
          image = "ghcr.io/meshcloud/unipipe-service-broker:latest"

          port {
            name           = "http"
            container_port = 8075
          }

          env_from {
            secret_ref {
              name = "unipipe-vmaas-config"
            }
          }
        }

        container {
          name  = "unipipe-terraform-runner"
          image = "ghcr.io/meshcloud/unipipe-terraform-runner:latest"

          env_from {
            secret_ref {
              name = "unipipe-vmaas-config"
            }
          }

          env_from {
            secret_ref {
              name = "unipipe-vmaas-tf-config"
            }
          }
        }
      }
    }
  }

  lifecycle {
    replace_triggered_by = [
      kubernetes_secret.unipipe_vmaas,
      kubernetes_secret.unipipe_vmaas_tf
    ]
  }
}
