terraform {
  backend "kubernetes" {
    namespace         = "unipipe-vmaas-likvid"
    secret_suffix     = "state"
  }
}
