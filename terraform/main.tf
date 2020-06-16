resource "aws_security_group" "sg_jenkins" {
    name        = "allow_http"
    description = "Allow http inbound traffic"
    vpc_id = data.aws_vpc.vpc.id
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${var.myip}/32"]
    }
    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["${var.myip}/32"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

data "aws_ssm_parameter" "ami_jenkins" {
  name = "/project/jenkins"
}

#data "aws_ami" "iac-jenkins" {
#  most_recent = true
#  filter {
#    name   = "name"
#    values = ["jenkins*"]
#  }
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#  owners = ["self"]
#}

resource "aws_key_pair" "iac_keypair" {
  key_name   = "iac_keypair"
  public_key = file("~/.ssh/id_rsa.iac.pub")
}

resource "aws_instance" "jenkins" {
  #ami                    = data.aws_ami.iac-jenkins.id
  ami                    = data.aws_ssm_parameter.ami_jenkins.value
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.iac_keypair.id
  vpc_security_group_ids = [aws_security_group.sg_jenkins.id]
  subnet_id              = data.aws_subnet.subnet.id

  tags = {
    Name = "iac_jenkins"
  }
}

