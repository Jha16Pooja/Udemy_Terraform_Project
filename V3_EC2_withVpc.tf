provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
  ami = "ami-0440d3b780d96b29d"
  instance_type = "t2.micro"
  key_name = "CompleteProject"
  //security_groups = ["demo-sg"]
  vpc_security_group_ids = [ aws_security_group.demo-sg.id ]
  subnet_id = aws_subnet.dpp-public-subnet01.id
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id      = aws_vpc.dpp-vpc.id

// Ingress rules (inbound traffic)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from anywhere
  }

  

  // Egress rules (outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }



  tags = {
    Name = "ssh-port"
  }
}

resource "aws_vpc" "dpp-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "dpp-vpc"
  }
}

resource "aws_subnet" "dpp-public-subnet01" {
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dpp-public-subnet01"
  }
}

resource "aws_subnet" "dpp-public-subnet02" {
 vpc_id = aws_vpc.dpp-vpc.id
 cidr_block = "10.1.2.0/24"
 map_public_ip_on_launch = "true"
 availability_zone = "us-east-1a"
 tags = {
  Name = "dpp-public-subnet02"
 } 
}

resource "aws_internet_gateway" "dpp-igw" {
  vpc_id =  aws_vpc.dpp-vpc.id
  tags = {
    Name = "dpp-igw"
  }
}

resource "aws_route_table" "dpp-public-rt" {
  vpc_id = aws_vpc.dpp-vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpp-igw.id
  }
}


resource "aws_route_table_association" "dpp-rta-subnet-01" {
  subnet_id = aws_subnet.dpp-public-subnet01.id
  route_table_id = aws_route_table.dpp-public-rt.id
}

resource "aws_route_table_association" "dpp-rta-subnet-02" {
  subnet_id = aws_subnet.dpp-public-subnet02.id 
  route_table_id = aws_route_table.dpp-public-rt.id
}