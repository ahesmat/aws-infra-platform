data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "main" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data = <<-USERDATA
    #!/bin/bash
    set -e

    # Install nginx and SSM agent
    dnf update -y
    dnf install -y nginx amazon-ssm-agent

    # Start and enable services
    systemctl enable nginx
    systemctl start nginx
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

    # Basic placeholder page
    echo "<h1>aws-infra-platform is running</h1>" > /usr/share/nginx/html/index.html
  USERDATA

  user_data_replace_on_change = true

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  tags = {
    Name = "${var.project}-${var.environment}-ec2"
  }
}
