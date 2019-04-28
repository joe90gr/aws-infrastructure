variable "access_key_aws" {}
variable "secret_key_aws" {}
variable "domain_name" {}
variable "region" {}
variable image {}
variable instance_type {}
variable key_name {}

module "snippets" {
  source = "./modules/snippets"

  access_key = "${var.access_key_aws}"
  secret_key = "${var.secret_key_aws}"
  domain_name = "${var.domain_name}"
  region = "${var.region}"
  image = "${var.image}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
}

output "blah-es-asg" {
  value = "${module.snippets.ip}"
  description = "The public IP address of the main server instance."
}