provider "aws" {
  region = var.aws_region
  # Perfil configurado localmente para deployar nuestra infra
}


module "S3-Bucket-State" {
  source = "./Modules/S3-Bucket"
}


data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_ami" "ubuntu" {
  most_recent = "true"

  # Imagen con S0 Linux
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


  owners = ["099720109477"]
}

// VPC 
resource "aws_vpc" "arroyo_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "arroyo_vpc"
  }
}

// Internet Gateway que adjunta a la VPC
resource "aws_internet_gateway" "arroyo_igw" {
  vpc_id = aws_vpc.arroyo_vpc.id

  tags = {
    Name = "arroyo_igw"
  }
}

resource "aws_subnet" "arroyo_public_subnet" {
  count             = var.subnet_count.public
  vpc_id            = aws_vpc.arroyo_vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "arroyo_public_subnet_${count.index}"
  }
}

resource "aws_subnet" "arroyo_private_subnet" {
  count             = var.subnet_count.private
  vpc_id            = aws_vpc.arroyo_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "arroyo_private_subnet_${count.index}"
  }
}

// Route table
resource "aws_route_table" "arroyo_public_rt" {
  vpc_id = aws_vpc.arroyo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.arroyo_igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count.public
  route_table_id = aws_route_table.arroyo_public_rt.id
  subnet_id      = aws_subnet.arroyo_public_subnet[count.index].id
}

resource "aws_route_table" "arroyo_private_rt" {
  vpc_id = aws_vpc.arroyo_vpc.id
}

resource "aws_route_table_association" "private" {
  count          = var.subnet_count.private
  route_table_id = aws_route_table.arroyo_private_rt.id
  subnet_id      = aws_subnet.arroyo_private_subnet[count.index].id
}

// Security Group
resource "aws_security_group" "arroyo_web_sg" {
  name        = "arroyo_web_sg"
  description = "Security group for arroyo web servers"
  vpc_id      = aws_vpc.arroyo_vpc.id

  ingress {
    description = "Allow all traffic through HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from my computer"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "arroyo_web_sg"
  }
}

resource "aws_security_group" "arroyo_db_sg" {
  name        = "arroyo_db_sg"
  description = "Security group for arroyo databases"
  vpc_id      = aws_vpc.arroyo_vpc.id

  ingress {
    description     = "Allow MySQL traffic from only the web sg"
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [aws_security_group.arroyo_web_sg.id]
  }

  tags = {
    Name = "arroyo_db_sg"
  }
}

resource "aws_db_subnet_group" "arroyo_db_subnet_group" {
  name        = "arroyo_db_subnet_group"
  description = "DB subnet group for arroyo"

  subnet_ids = [for subnet in aws_subnet.arroyo_private_subnet : subnet.id]
}

resource "aws_db_instance" "arroyo_database" {
  allocated_storage      = var.settings.database.allocated_storage
  engine                 = var.settings.database.engine
  engine_version         = var.settings.database.engine_version
  instance_class         = var.settings.database.instance_class
  db_name                = var.settings.database.db_name
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.arroyo_db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.arroyo_db_sg.id]
  skip_final_snapshot    = var.settings.database.skip_final_snapshot
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "arroyo_kp" {
  key_name   = "arroyo_kp"
  public_key = tls_private_key.key.public_key_openssh
}

data "template_file" "init" {

  template = file("userdata.tpl")

}

resource "aws_instance" "arroyo_web" {
  count                  = var.settings.web_app.count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.settings.web_app.instance_type
  subnet_id              = aws_subnet.arroyo_public_subnet[count.index].id
  key_name               = aws_key_pair.arroyo_kp.key_name
  vpc_security_group_ids = [aws_security_group.arroyo_web_sg.id]
  user_data              = data.template_file.init.rendered

  tags = {
    Name = "arroyo_web_${count.index}"
  }
}

resource "aws_eip" "arroyo_web_eip" {
  count    = var.settings.web_app.count
  instance = aws_instance.arroyo_web[count.index].id

  tags = {
    Name = "arroyo_web_eip_${count.index}"
  }
}