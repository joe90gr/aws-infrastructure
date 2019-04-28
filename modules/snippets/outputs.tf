output "ip" {
  value = "${aws_eip.ip.public_ip}"
  description = "The public IP address of the main server instance."
}