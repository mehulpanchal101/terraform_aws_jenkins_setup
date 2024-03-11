provider "aws" {
  region = local.region # or your preferred region
}

# Create VPC
resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create Subnet
resource "aws_subnet" "jenkins_subnet" {
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a" # Replace with desired AZ
}

# Create Security Group
resource "aws_security_group" "jenkins_security_group" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins EC2 instance"

  vpc_id = aws_vpc.jenkins_vpc.id
  #Allow incoming TCP requests on port 22 from any IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Allow incoming TCP requests on port 443 from any IP
  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id
}

# Create Route Table
resource "aws_route_table" "jenkins_route_table" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "jenkins_route_table_association" {
  subnet_id      = aws_subnet.jenkins_subnet.id
  route_table_id = aws_route_table.jenkins_route_table.id
}

# Create Elastic IP
resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins_server.id # Associate Elastic IP with the EC2 instance
}

# Create EC2 Instance
resource "aws_instance" "jenkins_server" {
  ami                         = "ami-03bb6d83c60fc5f7c" # Your Ubuntu AMI
  instance_type               = "t2.micro"
  key_name                    = "aws_admin_key" # Replace with your SSH key name
  subnet_id                   = aws_subnet.jenkins_subnet.id
  security_groups             = [aws_security_group.jenkins_security_group.id]
  associate_public_ip_address = false
  user_data                   = file("install_jenkins.sh")
  tags = {
    Name = "JenkinsServer"
  }
}

# Output the public IP address of the Jenkins EC2 instance
output "public_ip" {
  value       = aws_instance.jenkins_server.public_ip
  description = "Public IP Address of EC2 instance"
}

output "instance_id" {
  value       = aws_instance.jenkins_server.id
  description = "Instance ID"
}

#Create S3 bucket for Jenksin Artifacts
resource "aws_s3_bucket" "jenkins-s3-bucket" {
  bucket = "jenkins-s3-bucket-week2024terraform"

  tags = {
    Name = "Jenkins-Server"
  }
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.jenkins-s3-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

#make sure is prive and not open to public and create Access control List
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket     = aws_s3_bucket.jenkins-s3-bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}
