resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ami.image_id
  instance_type          = "t2.large"
  key_name               = var.key-name
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.security-group.id]

  # CHANGE: Reference the existing LabRole directly
  iam_instance_profile   = var.iam-role  # Uses "LabRole" from tfvars

  root_block_device {
    volume_size = 30
  }

  #user_data = templatefile("./tools-install.sh", {})

  user_data = templatefile("${path.module}/tools-install.sh", {
    LOG_FILE = "/var/log/user-data-install.log"
  })
  
  tags = {
    Name = var.instance-name
  }
}