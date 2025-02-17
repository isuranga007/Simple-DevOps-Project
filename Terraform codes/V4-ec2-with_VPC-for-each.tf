provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    key_name = "Dev-ops"
    //security_groups = [ "demo-sg" ]
    vpc_security_group_ids = [aws_security_group.demo-sg.id ]
    subnet_id = aws_subnet.TF-public-subnet01.id
    for_each = toset(["Jenkins-master", "Build-slave","ansible"])
    tags = {
     Name = "${each.key}"
   }
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.TF-vpc.id

  ingress {
    description      = "Shh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-prot"

  }
}

resource "aws_vpc" "TF-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "TF-vpc"
  }
}
resource "aws_subnet" "TF-public-subnet01" {
  vpc_id = aws_vpc.TF-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "TF-public-subent-01"
  }
}

resource "aws_subnet" "TF-public-subnet02" {
  vpc_id = aws_vpc.TF-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    Name = "TF-public-subent-02"
  }
}

resource "aws_internet_gateway" "TF-igw" {
  vpc_id = aws_vpc.TF-vpc.id
  tags = {
    Name = "TF-tgw"
  }
}
resource "aws_route_table" "TF-public-rt" {
  vpc_id = aws_vpc.TF-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TF-igw.id

  }
}

resource "aws_route_table_association" "TF-rta-public-subnet-01" {
 subnet_id = aws_subnet.TF-public-subnet01.id
 route_table_id = aws_route_table.TF-public-rt.id
}

resource "aws_route_table_association" "TF-rta-public-subnet-02" {
 subnet_id = aws_subnet.TF-public-subnet02.id
 route_table_id = aws_route_table.TF-public-rt.id
}
 
