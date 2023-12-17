
terraform {
  required_providers {
    kubernetes = {}
  }
}

variable "k8s" {
  type = object({
    config_path = string
  })
}

provider "kubernetes" {
  config_path = var.k8s.config_path
}

resource "kubernetes_pod_v1" "node_app" {
  metadata {
    name = "node-app"
  }
  spec {
    container {
      name  = "node-app"
      image = "42kbit/test-node-app:latest"

      port {
        container_port = 80
      }
    }
  }
}
