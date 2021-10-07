locals {
  domain_name = "jenkins.${var.hosted_zone_name}"
}

resource "aws_security_group" "sg_jenkins" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = data.aws_subnet.subnet.vpc_id

  # Port 80 is required for certbot init (letsencrypt)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

resource "aws_ssm_parameter" "jenkins" {
  name  = "/project/jenkins/instance"
  type  = "String"
  value = aws_instance.jenkins.id
}

resource "aws_instance" "jenkins" {
  ami                         = data.aws_ssm_parameter.ami_jenkins.value
  instance_type               = "t3.small"
  vpc_security_group_ids      = [aws_security_group.sg_jenkins.id]
  subnet_id                   = data.aws_subnet.subnet.id
  associate_public_ip_address = var.public_ip
  iam_instance_profile        = aws_iam_instance_profile.jenkins.name
  user_data = templatefile("${path.module}/user-data.tpl", {
    domain_name   = local.domain_name
    backup_bucket = aws_s3_bucket.jenkins_backup.bucket
  })

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
  name    = local.domain_name
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

resource "aws_iam_role_policy" "jenkins" {
  name = "jenkins-policy"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.jenkins_backup.arn}/*"
        ]
      },
    ]
  })
}
resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins.name
}

resource "aws_s3_bucket" "jenkins_backup" {
  bucket = "fr.revolve.esiea.jenkins.backup.${data.aws_caller_identity.current.account_id}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "jenkins_backup" {
  bucket = aws_s3_bucket.jenkins_backup.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}