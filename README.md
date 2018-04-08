# Terraform and Ansible deploy #

The repository contains a Terraform script that deploys an environment in AWS. Composed by an
 EC2 instance, an S3 instance and a RDS instance (postgres). All the environment could be deployed with [AWS Free Tier](https://aws.amazon.com/free/)

Also contains an Ansible script to install docker, and to pull and run an image from DockerHub with a simple Django [project](https://github.com/alexisCata/django_helloworld) that connects to the RDS instance created before. 

I decided to use Ansible to install Docker and deploy the Django project to separate the deployment of the architecture from projects deployment.
This is a first approach to use Terraform and Ansible so I tried to follow the KISS principle.

Versions:
- Terraform v0.11.5
    + provider.aws v1.13.0
- ansible 2.5.0


#### Prerequisites

Download [Terraform](https://www.terraform.io/downloads.html)
```
sudo apt-add-repository ppa:ansible/ansible
```
```
sudo apt-get install ansible 
```
```
ansible-galaxy install mongrelion-docker
```


## Use

Is considered that the script is running on ~/terraform_ansible_deploy/terraform with ssh keys on ~/.ssh
 
In other case, create a ssh key 

    ssh-keygen -t rsa
     
Or add a variable on file terraform.tfvars
>ssh_pub = path_id_rsa.pub


and add a variable on file /provision/inventory/host
> ansible_ssh_private_key_file=path_id_rsa.pem

##### Terraform:
Update file terraform/terraform.tfvars with your AWS keys
> access_key = "YOUR_AWS_ACCES_KEY"

> secret_key = "YOUR_AWS_SECRET_KEY"

```
cd terraform
```
```
terraform init
```
```
terraform apply
```
When the apply finishes it returns output like:
```
Outputs:

postgres_host = terraform-20180408111143467300000001.cuycxx9sahds.us-east-1.rds.amazonaws.com
server_ip = 34.227.68.224

```
##### Ansible:

You have to copy the server_ip and update it on /provision/inventory/host
```
[server]
34.227.68.224
```
Then copy server_ip and postgres_host and update it on /provision/vars.yml
```
db_host: terraform-20180408111143467300000001.cuycxx9sahds.us-east-1.rds.amazonaws.com
ip: 34.227.68.224
```
Now you are ready to execute the Ansible script
```
cd provision
```
```
ansible-playbook -i inventory/hosts site.yml
```
And finally if everything gone well, with the ip given by terraform you can visit http://34.227.68.224 and it will show the DB host the databases and the version connected to Django.
>Hello, world!!!!!! ----- DB Host: terraform-20180408135441117700000001.cuycxx9sahds.us-east-1.rds.amazonaws.com ----- DB Version: ('PostgreSQL 9.5.2 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.8.3 20140911 (Red Hat 4.8.3-9), 64-bit',) ----- DB databases: [('template0',), ('rdsadmin',), ('template1',), ('postgres',), ('my_db',)]


## Terraform script

#### main.tf

**aws_instance**: It deploys an EC2. It has associated a **aws_security_group** a terraform resource to allow network connections. Also has an attribute called user_data that provides data when the instance when launching. In my case provides an script to install python-minimal

**aws_s3_bucket**: An S3 bucket

**aws_iam_user**: Identity access management user. User to access instances.

**aws_key_pair**: Provides an EC2 key pair to control login in the EC2 instance. Where you associate your ssh key.

**aws_iam_access_key**: Credentials associated to an user that allow API request to be made as IAM user.

**aws_iam_policy**: Provides a policy.

**aws_iam_policy_attachment**: Associates a policy to an IAM user.

**aws_db_instance**: RDS instance. Also requires a **aws_security_group** to allow connections.

**aws_security_group**:resource to define networking ingress and egress rules.

#### variables.tf

File to define Terraform variables.

#### terraform.tfvars

Template to add AWS credentials and DB login.


## Ansible script
You can find it on /provision. It uses a role from ansible-galaxy (Ansible content repository) 
to install Docker, commands pip to install docker python packages and shell to pull and 
run the Docker image to expose on port 80 a Django project.

#### bootstrap.yml
Tasks for install docker and some docker python packages

#### run.yml
Tasks for pull and run the docker images



_Note: I started first with an ansible script placed at /provision_old to deploy the Django project directly with Ansible
but finally I decided to discard it because nowadays is not a proper way to deploy a project, so I do it with Docker, but anyways 
only use Docker is not be the best option, so I recommend to use some COEs like Kubernetes, Docker Swarm or Mesos._

## Dependencies
    
[Terraform](https://www.terraform.io/)

[Ansible](https://www.ansible.com/)

[Ansible Galaxy](https://galaxy.ansible.com/)
