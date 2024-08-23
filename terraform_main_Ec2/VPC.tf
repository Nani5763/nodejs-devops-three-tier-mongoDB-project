#Create VPC
resource "aws_vpc" "dev" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "project-vpc"
    }
}
#Create Internet Gateway and attach VPC
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.dev.id
    tags = {
      Name = "project-igw"
    }
  
}
#Create Public-subnet-1
resource "aws_subnet" "public-subnet-1" {
    cidr_block = "10.0.1.0/24"
    vpc_id = aws_vpc.dev.id
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
      Name = "public-subnet-1"
    }
  
}
#Create Public-subnet-2
resource "aws_subnet" "public-subnet-2" {
    cidr_block = "10.0.2.0/24"
    vpc_id = aws_vpc.dev.id
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
    tags = {
      Name = "public-subnet-2"
    }
  
}
#Create Route Table and Attach internet Gateway
resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.dev.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name = "project-rt"
    }
  
}
#RouteTable Association public-subnet-1
resource "aws_route_table_association" "rta-1" {
    subnet_id = aws_subnet.public-subnet-1.id
    route_table_id = aws_route_table.rt.id
  
}
#RouteTable Association public-subnet-2
resource "aws_route_table_association" "rta-2" {
  subnet_id = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.rt.id
}
#Create Security Group
resource "aws_security_group" "sg" {
    vpc_id = aws_vpc.dev.id
    description = "Allowing Jenkins, SonarQube, SSH Access"

    ingress = [  
        for port in [22, 8080, 9000, 9090, 80] : {
            description      = "TLS from VPC"
            from_port        = port
            to_port          = port
            protocol         = "tcp"
            ipv6_cidr_blocks = ["::/0"]
            self             = false
            prefix_list_ids  = []
            security_groups  = []
            cidr_blocks      = ["0.0.0.0/0"]
        }
    ]

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "project-sg"
    }
}