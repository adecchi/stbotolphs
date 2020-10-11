resource "kubernetes_ingress" "stbotolphs-ingress" {
  metadata {
    name      = "stbotolphs-ingress"
    namespace = "stbotolphs"
    annotations = {
      "kubernetes.io/ingress.class"                        = "nginx"
      "nginx.ingress.kubernetes.io/add-base-url"           = "true"
      "nginx.ingress.kubernetes.io/session-cookie-name"    = "stbotolphs"
      "nginx.ingress.kubernetes.io/session-cookie-expires" = "172800"
      "nginx.ingress.kubernetes.io/session-cookie-max-age" = "172800"
      "nginx.ingress.kubernetes.io/ssl-redirect"           = "false"
      "nginx.ingress.kubernetes.io/affinity-mode"          = "persistent"
      "nginx.ingress.kubernetes.io/session-cookie-hash"    = "sha1"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    rule {
      host = "stbotolphs.decchi.com.ar"
      http {
        path {
          backend {
            service_name = "stbotolphs-nlb-service"
            service_port = 80
          }
          path = "/"
        }
      }

    }
  }
}

resource "kubernetes_ingress" "mailhog-ingress" {
  metadata {
    name      = "mailhog-ingress"
    namespace = "stbotolphs"
    annotations = {
      "kubernetes.io/ingress.class"                        = "nginx"
      "nginx.ingress.kubernetes.io/add-base-url"           = "true"
      "nginx.ingress.kubernetes.io/session-cookie-name"    = "mailhog"
      "nginx.ingress.kubernetes.io/session-cookie-expires" = "172800"
      "nginx.ingress.kubernetes.io/session-cookie-max-age" = "172800"
      "nginx.ingress.kubernetes.io/ssl-redirect"           = "false"
      "nginx.ingress.kubernetes.io/affinity-mode"          = "persistent"
      "nginx.ingress.kubernetes.io/session-cookie-hash"    = "sha1"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"

    }
  }
  spec {
    rule {
      host = "mailhog.decchi.com.ar"
      http {
        path {
          backend {
            service_name = "mailhog-webadminsmtp-nlb-service"
            service_port = 8002
          }
          path = "/"
        }
      }

    }

  }
  depends_on = [kubernetes_namespace.stbotolphs]
}

