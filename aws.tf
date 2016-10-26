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
    cidr_blocks = ["199.38.154.0/24"]
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
//Create the bucket to hold software temp.  You will add the policy further down due to needing the IP address of the os_nexus1 instance
resource "aws_s3_bucket" "openshift_s3_bucket" {
  bucket = "openshifts3bucket"
}

//Creates the IAM instance profile that will be assigned to the ec2 server made of an instance policy attached to an sts allow role
resource "aws_iam_instance_profile" "test_profile" {
    name = "test_profile"
    roles = ["${aws_iam_role.nexus_instance_role.name}"]
}

//Creates the policy that will be attached to the ec2 assume role
resource "aws_iam_role_policy" "nexus_instance_policy" {
    name = "openshift_test_policy"
    role = "${aws_iam_role.nexus_instance_role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1477509636623",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::openshifts3bucket/*"
    }
  ]
}
EOF
}

//Creates the role that will be assigned to the iam_instance_profile of the instance
resource "aws_iam_role" "nexus_instance_role" {
    name = "openshift_test_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

//This is the def of the policy and is applied to a policy resource
data "aws_iam_policy_document" "os_s3_pol" {
    statement {
      sid = "IPAllow"
      effect = "Allow"
      actions = ["s3:*"]
      resources = ["arn:aws:s3:::openshifts3bucket/*"]
      principals = {
        type = "AWS"
        identifiers = ["*"]
      }
      condition {
            test = "IpAddress"
            variable = "aws:SourceIp"
            values = ["73.210.192.218/32", "${aws_instance.os_nexus1.public_ip}"]
        }
    }
}

//Assign the policy document to the bucket
resource "aws_s3_bucket_policy" "openshift_bucket_policy" {
  bucket = "${aws_s3_bucket.openshift_s3_bucket.bucket}"
  policy = "${data.aws_iam_policy_document.os_s3_pol.json}"
}

//Copy the nexus binary to the bucket
resource "aws_s3_bucket_object" "nexus_object" {
    bucket = "openshifts3bucket"
    key = "nexus-3.0.2-02-unix.tar.gz"
    source = "./nexus-3.0.2-02-unix.tar.gz"
    etag = "${md5(file("./nexus-3.0.2-02-unix.tar.gz"))}"
}

//Creates the instance that nexus will be installed on.
resource "aws_instance" "os_nexus1" {
    ami = "ami-2d39803a"
    instance_type = "t2.small"
    subnet_id = "subnet-49f27362"
    key_name = "ostempkey"
    user_data = "${file("./user_data.sh")}"
    vpc_security_group_ids = ["${aws_security_group.osproducers.id}", "${aws_security_group.osconsumers.id}"]
    iam_instance_profile = "${aws_iam_instance_profile.test_profile.id}"
    tags {
        Name = "OC-Nexus"
    }
}