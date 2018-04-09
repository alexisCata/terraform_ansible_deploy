variable "access_key" {}

variable "secret_key" {}

variable "region" {
  default = "us-east-1"
}

variable "ami" {
  description = "Ubuntu Xenial 16.04 LTS (ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180306)"
  default = "ami-43a15f3e"
}

variable "instance_type" {
  description = "EC2 Instance type"
  default = "t2.micro"
}

variable "bootstrap_path" {
  description = "Script to install Python 3"
  default = "bootstrap/install_python_minimal.sh"
}

variable "ssh_pub" {
	description = "public key"
	default = "~/.ssh/id_rsa.pub"
}
variable "bucket_name" {
    default = "my-s3-bucket-alexis-789"
}
variable "acl" {
	default  = "private"
}

variable "tags" {
	type = "map"
	default = {
    	name        = "My S3 bucket"
    	Environment = "Dev"
  	}
}

variable "db_name" {
	description = "Mysql database name"
	default = "my_db"
}
variable "db_user" {
	description = "Mysql database user"
}
variable "db_pass" {
	description = "Mysql database password"
}

variable "db_instance_class" {
	description = "Mysql database instance class"
	default = "db.t2.micro"
}
