/*
Comes mostly from: https://github.com/gruntwork-io/terraform-kubernetes-helm/tree/master/modules/k8s-tiller-tls-certs
*/

variable "ca_tls_subject" {
  description = "The issuer information that contains the identifying information for the CA certificates. See https://www.terraform.io/docs/providers/tls/r/cert_request.html#common_name for a list of expected keys. Note that street_address must be a newline separated string as opposed to a list of strings."
  # We use an string type here instead of directly specifying the object, to allow certain keys to be optional.
  type        = map(string)
}

variable "signed_tls_subject" {
  description = "The issuer information that contains the identifying information for the signed certificates. See https://www.terraform.io/docs/providers/tls/r/cert_request.html#common_name for a list of expected keys. Note that street_address must be a newline separated string as opposed to a list of strings."
  # We use an string type here instead of directly specifying the object, to allow certain keys to be optional.
  type        = map(string)
}

variable "private_key_algorithm" {
  description = "The name of the algorithm to use for private keys. Must be one of: RSA or ECDSA."
  type        = string
  default     = "ECDSA"
}

variable "private_key_ecdsa_curve" {
  description = "The name of the elliptic curve to use. Should only be used if var.private_key_algorithm is ECDSA. Must be one of P224, P256, P384 or P521."
  type        = string
  default     = "P256"
}

variable "private_key_rsa_bits" {
  description = "The size of the generated RSA key in bits. Should only be used if var.private_key_algorithm is RSA."
  type        = number
  default     = 2048
}

variable "ca_tls_certs_allowed_uses" {
  description = "List of keywords from RFC5280 describing a use that is permitted for the CA certificate. For more info and the list of keywords, see https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html#allowed_uses."
  type        = list(string)

  default = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

variable "signed_tls_certs_allowed_uses" {
  description = "List of keywords from RFC5280 describing a use that is permitted for the issued certificate. For more info and the list of keywords, see https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html#allowed_uses."
  type        = list(string)

  default = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "ca" {

  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits
}

resource "tls_self_signed_cert" "ca" {

  key_algorithm     = element(concat(tls_private_key.ca.*.algorithm, [""]), 0)
  private_key_pem   = element(concat(tls_private_key.ca.*.private_key_pem, [""]), 0)
  is_ca_certificate = true

  # Certificate expires after 12 hours.
  validity_period_hours = 12

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 3

  allowed_uses = var.ca_tls_certs_allowed_uses

  subject {
    common_name         = lookup(var.ca_tls_subject, "common_name", null)
    organization        = lookup(var.ca_tls_subject, "organization", null)
    organizational_unit = lookup(var.ca_tls_subject, "organizational_unit", null)
    street_address      = local.ca_tls_subject_maybe_street_address != "" ? split("\n", local.ca_tls_subject_maybe_street_address) : []
    locality            = lookup(var.ca_tls_subject, "locality", null)
    province            = lookup(var.ca_tls_subject, "province", null)
    country             = lookup(var.ca_tls_subject, "country", null)
    postal_code         = lookup(var.ca_tls_subject, "postal_code", null)
    serial_number       = lookup(var.ca_tls_subject, "serial_number", null)
  }
}

locals {
  ca_tls_subject_maybe_street_address = lookup(var.ca_tls_subject, "street_address", "")
}

# ---------------------------------------------------------------------------------------------------------------------
# STORE CA CERTIFICATE IN KUBERNETES SECRET
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_secret" "ca-secret" {

  metadata {
    namespace = var.traefik_namespace
    name      = "ca-secret"
  }

  data = {
    "ca.pem" = element(concat(tls_private_key.ca.*.private_key_pem, [""]), 0)
    "ca.pub" = element(concat(tls_private_key.ca.*.public_key_pem, [""]), 0)
    "ca.crt" = element(concat(tls_self_signed_cert.ca.*.cert_pem, [""]), 0)
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A TLS CERTIFICATE SIGNED USING THE CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "cert" {

  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits
}

resource "tls_cert_request" "cert" {

  key_algorithm   = element(concat(tls_private_key.cert.*.algorithm, [""]), 0)
  private_key_pem = element(concat(tls_private_key.cert.*.private_key_pem, [""]), 0)

  dns_names    = [var.domain]
  ip_addresses = ["127.0.0.1"]

  subject {
    common_name         = lookup(var.signed_tls_subject, "common_name", null)
    organization        = lookup(var.signed_tls_subject, "organization", null)
    organizational_unit = lookup(var.signed_tls_subject, "organizational_unit", null)
    street_address      = local.signed_tls_subject_maybe_street_address != "" ? split("\n", local.signed_tls_subject_maybe_street_address) : []
    locality            = lookup(var.signed_tls_subject, "locality", null)
    province            = lookup(var.signed_tls_subject, "province", null)
    country             = lookup(var.signed_tls_subject, "country", null)
    postal_code         = lookup(var.signed_tls_subject, "postal_code", null)
    serial_number       = lookup(var.signed_tls_subject, "serial_number", null)
  }
}

locals {
  signed_tls_subject_maybe_street_address = lookup(var.signed_tls_subject, "street_address", "")
}

resource "tls_locally_signed_cert" "cert" {

  cert_request_pem = element(concat(tls_cert_request.cert.*.cert_request_pem, [""]), 0)

  ca_key_algorithm   = element(concat(tls_private_key.ca.*.algorithm, [""]), 0)
  ca_private_key_pem = element(concat(tls_private_key.ca.*.private_key_pem, [""]), 0)
  ca_cert_pem        = element(concat(tls_self_signed_cert.ca.*.cert_pem, [""]), 0)

  # Certificate expires after 12 hours.
  validity_period_hours = 12

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 3

  allowed_uses = var.signed_tls_certs_allowed_uses
}

# ---------------------------------------------------------------------------------------------------------------------
# STORE SIGNED TLS CERTIFICATE IN KUBERNETES SECRET
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_secret" "signed-tls" {

  metadata {
    namespace = var.traefik_namespace
    name      = "signed-tls"
  }

  data = {
    "tls.pem" = element(concat(tls_private_key.cert.*.private_key_pem, [""]), 0)
    "tls.pub" = element(concat(tls_private_key.cert.*.public_key_pem, [""]), 0)
    "tls.crt" = element(concat(tls_locally_signed_cert.cert.*.cert_pem, [""]), 0)
    "ca.crt"  = element(concat(tls_self_signed_cert.ca.*.cert_pem, [""]), 0)
  }
}

resource "kubernetes_secret" "signed-tls-2" {
  metadata {
    name      = "signed-tls-2"
    namespace = var.traefik_namespace
  }
  type = "tls"
  data = {
    "tls.crt" = element(concat(tls_locally_signed_cert.cert.*.cert_pem, [""]), 0)
    "tls.key" = element(concat(tls_private_key.cert.*.private_key_pem, [""]), 0)
  }
}

resource "kubernetes_manifest" "tls-store" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "TLSStore"
    "metadata"   = {
      "name"      = "tls-store"
      "namespace" = var.traefik_namespace
    }
    "spec"       = {
      "defaultCertificate" = {
        "secretName" = kubernetes_secret.signed-tls-2.metadata[0].name
      }
    }
  }
}
