provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "my_instance" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = true
  key_name = "${aws_key_pair.deploy.key_name}"
  vpc_security_group_ids = ["${aws_security_group.security.id}"]
  user_data = "${file("${var.bootstrap_path}")}"

}

resource "aws_key_pair" "deploy" {
  key_name = "deploy"
  public_key = "${file("${var.ssh_pub}")}"
}

resource "aws_iam_user" "my_user" {
    name = "my_user"
}

resource "aws_iam_access_key" "my_user" {
    user = "${aws_iam_user.my_user.name}"
}

resource "aws_iam_policy" "my_policy" {
  name = "my_user_policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadForGetTestBucketObjects",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::myBucket/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::myBucket",
                "arn:aws:s3:::myBucket/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "${var.bucket_name}"
  acl = "${var.acl}"

  tags {
    Name        = "My S3 bucket"
    Environment = "Dev"
  }
}

resource "aws_iam_policy_attachment" "s3_user_policy_attachment" {
  name       = "policy-attachment"
  users      = ["${aws_iam_user.my_user.name}"]
  policy_arn = "${aws_iam_policy.my_policy.arn}"
}

resource "aws_db_instance" "my_postgres_db" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "9.5.2"
  instance_class       = "${var.db_instance_class}"
  name                 = "${var.db_name}"
  username             = "${var.db_user}"
  password             = "${var.db_pass}"
  parameter_group_name = "default.postgres9.5"
  publicly_accessible = true
  skip_final_snapshot = true
  vpc_security_group_ids = ["${aws_security_group.security_db.id}"]
}


resource "aws_security_group" "security" {
  name = "security"
  tags {
        Name = "security"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

# Enable ICMP
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "security_db" {
  name = "security_db"
  tags {
        Name = "security_db"
  }

  ingress {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }


}




output "server_ip" {
  value = "${aws_instance.my_instance.public_ip}"
}

output "db_host" {
  value = "${aws_db_instance.my_postgres_db.address}"
}