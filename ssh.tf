resource "tls_private_key" "default" {
  algorithm = var.ssh_key_algorithm
}

resource "aws_key_pair" "generated" {
  depends_on = [tls_private_key.default]
  key_name   = var.name
  public_key = tls_private_key.default.public_key_openssh
  tags       = {}
}

resource "local_file" "public_key_openssh" {
  depends_on = [tls_private_key.default]
  content    = tls_private_key.default.public_key_openssh
  filename   = "${var.ssh_public_key_path}/${var.name}.pub"
}

resource "local_sensitive_file" "private_key_pem" {
  depends_on      = [tls_private_key.default]
  content         = tls_private_key.default.private_key_pem
  filename        = "${var.ssh_public_key_path}/${var.name}.pem"
  file_permission = "0600"
}
