resource "aws_security_group" "sg_jenkins" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = data.aws_subnet.subnet.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
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

data "aws_ssm_parameter" "ami_jenkins" {
  name = "/project/jenkins"
}

resource "aws_instance" "jenkins" {
  ami                         = data.aws_ssm_parameter.ami_jenkins.value
  instance_type               = "t3.small"
  vpc_security_group_ids      = [aws_security_group.sg_jenkins.id]
  subnet_id                   = data.aws_subnet.subnet.id
  associate_public_ip_address = var.public_ip
  iam_instance_profile        = aws_iam_instance_profile.jenkins.name

  tags = {
    Name = "Jenkins Automation"
  }
}

resource "aws_eip" "jenkins" {
  vpc   = true
  count = var.static_ip ? 1 : 0
}

resource "aws_eip_association" "jenkins" {
  instance_id   = aws_instance.jenkins.id
  allocation_id = aws_eip.jenkins[0].id
  count         = var.static_ip ? 1 : 0
}

resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "jenkins.${var.hosted_zone_name}"
  type    = "A"
  ttl     = "300"
  records = var.static_ip ? [aws_eip.jenkins[0].public_ip] : (var.public_ip ? [aws_instance.jenkins.public_ip] : [aws_instance.jenkins.private_ip])
}

resource "aws_iam_role" "jenkins" {
  name = "jenkins-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins.name
}
