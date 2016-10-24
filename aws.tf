provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
resource "aws_security_group" "osproducers" {
  name = "os_producers"
  vpc_id = "vpc-e6032a83"
  description = "Security group to group the openshift nodes"

  tags {
    name = "ossg1"
  }  
}

resource "aws_security_group" "osconsumers" {

  name = "os_consumer"
  vpc_id = "vpc-e6032a83"
  description = "Security group to allow all sources to intercommunicate and to talk out"

  ingress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    security_groups = ["${aws_security_group.osproducers.id}"]
    cidr_blocks = ["192.168.5.0/24"]
  }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    name = "ossg1"
  }
}