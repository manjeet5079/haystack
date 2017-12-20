locals {
  app_name = "trace-reader"
}

resource "kubernetes_replication_controller" "haystack-rc" {
  metadata {
    name = "${local.app_name}"
    labels {
      app = "${local.app_name}"
    }
    namespace = "${var.namespace}"
  }
  "spec" {
    replicas = "${var.replicas}"
    template {
      container {
        image = "${var.image}"
        name = "${local.app_name}"
      }
      termination_grace_period_seconds = "${var.termination_grace_period}"

    }

    "selector" {
      app = "${local.app_name}"
    }
  }
}