# terraform_web_nat_aws
Terraform and Packer scripts to spin up web server behind NAT gateway.

## Reference architecture:
![alt text](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/images/nat-gateway-diagram.png "Logo Title Text 1")

## Architecture

The above diagram is not the actual architecture, but is a Reference architecture.

Terraform script will spin up the following:

1) VPC with 10.0.0.0/16 CIDR

2) Two subnets, "public- 10.0.0.0/20" and " private- 10.0.16.0/20"

3) Creates internet gateway and a NAT gateway resources.

4) Creates two routing tables, one for public subnet which allows connection between instances in public subnet to the internet gateway and another for private subnet which allows traffic from internet to private subnet only via the NAT gateway.  

5) Finally an EC2 instance with Nginx web server, serving a simple html static page is place in the private subnet.

6) Only the EC2 instance which is in the private subnet can initiate connection to 0.0.0.0/0 (internet). No body can initiate connection from outside to this EC2 instance.

7) Unable to configure a firewall or exception for the the internet to connect to web server via http or ssh. But there is a security group which open connection to 0.0.0.0/0 for port 80 and 22, which does not work for simple reason that it is routed to NAT-Gateway.


## Instructions:

Required packer and terraform to be installed as pre-requisites.

1) Build the packer image. It is build form the base AMI ami-70edb016 (amazon linux-centos 6.5).

2) Nginx and a modified index.html page is placed on the packer image. NOTE down the AMI id which is generate at the end of packer build.

3) Run "packer validate web-server.json" to validate and "packer build web-server.json" to build the AMI.

4) In Terraform template main.tf: Enter AMI ID, your AWS access_key and secret_key along with the ssh key for the EC2 instance.

5) Run "terraform plan", review the plan.

6) Run "terraform apply" to build on aws.

7) Again run "terraform plan" to check the resources created against the local template.


any questions, contact me at bala529@gmail.com
