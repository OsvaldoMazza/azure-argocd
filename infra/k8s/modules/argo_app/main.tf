# modules/argo_app/main.tf

terraform {
  required_providers {
    argocd = {
      source = "oboukili/argocd"
    }
  }
}

resource "argocd_application" "webapp" {
  metadata {
    name      = "${var.base_name}-app"
    namespace = "argocd"
  }

  spec {
    project = "default"
    source {
      repo_url        = var.repo_url
      path            = "appfastapi"  # Set the path to your application in the Git repository
      target_revision = "master"      # Set the Branch or Tag you want to deploy
      helm {
        parameter {
          name  = "image.acrName"
          value = var.acr_name
        }
        parameter {
          name  = "image.baseName"
          value = var.base_name
        }
      }
    }
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "default"
    }
    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
    }
  }
}