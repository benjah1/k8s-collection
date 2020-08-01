provider "random" {}

resource "random_id" "gossip_key" {
  byte_length = 16
}

resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm     = "RSA"
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true

  subject {
    country         = "CA"
    locality            = "Toronto"
    organization        = "Labs"
    organizational_unit = "Consul"
    province            = "Ontario"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "tls_private_key" "consul" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "consul" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.consul.private_key_pem

  ip_addresses = ["127.0.0.1"]
  dns_names = ["server.dc1.cluster.local"]

  subject {
    country             = "CA"
    locality            = "Toronto"
    organization        = "Labs"
    organizational_unit = "Consul"
    province            = "Ontario"
  }
}

resource "tls_locally_signed_cert" "consul" {
  cert_request_pem   = tls_cert_request.consul.cert_request_pem
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "code_signing",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "kubernetes_secret" "consul" {
  metadata {
    name = "consul"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    "gossip-encryption-key" = random_id.gossip_key.b64_std
    "ca.pem" = tls_self_signed_cert.ca.cert_pem
    "consul.pem" = tls_locally_signed_cert.consul.cert_pem
    "consul-key.pem" = tls_private_key.consul.private_key_pem
  }
}
