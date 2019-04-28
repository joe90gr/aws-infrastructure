provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "snippets" {
  ami = "${var.image}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  tags {
    Name = "terraform-snippets"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.snippets.public_ip} > ./ip_address.txt"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user        = "ubuntu"
      private_key = "${file("~/.ssh/aws/id_aws_key1.pem")}"
    }

    inline = [
      "sudo apt update",
      "sudo apt-get -y install python2.7 python-pip"
      # "sudo groupadd docker",
      # "sudo usermod -aG docker $USER"
    ]
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-snippets-instance"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.snippets.id}"
}

data "aws_route53_zone" "primary" {
  name         = "${var.domain_name}"
  private_zone = false
}
resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "www.${data.aws_route53_zone.primary.name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.ip.public_ip}"]
}
