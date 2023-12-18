
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

resource "kubernetes_deployment_v1" "node_app" {
  metadata {
    name = "node-app"

    labels = {
      # here you can label your deployment (wooosh)
    }
  }
  spec {
    # select pod this deployment manages.
    # this is required.
    selector {
      match_labels = {
        test_label = "node-app-label"
      }
    }

    # template pod, that will be created due to autoscaling policy
    template {
      metadata {
        name = "node-app"

        # we'll need this to select this pod for deployment object.
        labels = {
          test_label = "node-app-label"
        }
      }
      spec {
        container {
          name  = "node-app"
          image = "42kbit/test-node-app:latest"

          port {
            container_port = 3000
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }

            initial_delay_seconds = 180 # wait 3 min for it to bootup
            period_seconds        = 3   # then start pinging constantly
          }

          resources {
            limits = {
              cpu    = "0.1"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }

  lifecycle {
    # since we want to update it and not destroy!
    prevent_destroy = true
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "prod_hpa" {
  metadata {
    name = "prod-hpa"

    labels = {
      env = "env-prod-hpa"
    }
  }
  spec {
    min_replicas = 2
    max_replicas = 10

    metric {
      # wont do much because we have no monitoring service but whatever
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }
    # here we specify deployment we want this hpa to attach to.
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment" # reference "kind"/"name"
      # in this case: Deployment/node-app

      # always index zero, because only one block is of metadata is permitted.
      name = kubernetes_deployment_v1.node_app.metadata[0].name
    }
  }
}

resource "kubernetes_service_v1" "node_app_cip" {
  metadata {
    name = "node-app-cip"
  }
  spec {
    # which pods route traffic to
    selector = kubernetes_deployment_v1.node_app.spec[0].template[0].metadata[0].labels

    # this is like sticky server in HAProxy
    # clients with the same fingerprint (hash) will usually connect
    # to the same server.
    # 
    # session_affinity = "ClientIP"

    # this will load balance the traffic between pods matched by selector.
    session_affinity = "None"
    port {
      port        = 80
      target_port = 3000
    }

    type = "ClusterIP"
  }
}
