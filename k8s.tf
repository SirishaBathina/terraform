provider "google" {
  credentials      = file("~/.siri.json")
  project          = "projectname"
  region           = "us-central1"
  zone             = "us-central1-c"
}

provider "google-beta" {
  credentials      = file("~/.siri.json")
  project          = "pj-name"
  region           = "us-central1"
  zone             = "us-central1-c"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

*******************************************************************
data "google_container_cluster" "gke_cluster" {
  name     = "test"
  location = "us-central1-c"
}

resource "kubernetes_namespace" "api" {
  metadata {
    name = "api"
  }
}

resource "kubernetes_config_map" "siri-config" {
  metadata {
    name      = "siri-config"
    namespace = "api"
  }

  data = {
    # Define your config key-value pairs here
    "SPRING_PROFILES_ACTIVE" = "test"
  }
}

resource "kubernetes_deployment" "analytics" {
  metadata {
    name      = "analytics"
    namespace = "api"
  }
  spec {

    replicas = 1

    selector {
      match_labels = {
        app = "analytics"
      }
    }

    template {
      metadata {
        labels = {
          app = "analytics"
        }
      }

      spec {
        container {
          name  = "analytics"
          image = "gcr.io/pj-name/siiri:test"

          port {
            container_port = 80
          }

          env {
            # Inject config map data as environment variables
            name = "SPRING_PROFILES_ACTIVE"
            value_from {
              config_map_key_ref {
                name = "test-config"
                key  = "SPRING_PROFILES_ACTIVE"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "test-service" {
  metadata {
    name      = "test-service"
    namespace = "api"
  }

  spec {
    selector = {
      app = "test"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort" # or "LoadBalancer" if external access is needed
  }
}
