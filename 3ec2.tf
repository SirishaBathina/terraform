provider "aws" {
  region = "us-west-2"  # Specify your desired AWS region
}

resource "aws_instance" "my_ec2" {
  count         = 3  # Number of instances to create
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with your desired AMI ID
  instance_type = "t2.micro"  # Replace with your desired instance type

  tags = {
    Name = "Terraform-EC2-Instance-${count.index + 1}"
  }
  }
