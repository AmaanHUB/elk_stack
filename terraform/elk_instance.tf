# Get the image, assumes created with Packer beforehand
data "aws_ami" "elk" {
  most_recent = "true"
  owners      = ["self"]

  filter {
    name   = "name"
    values = [var.elk_ami_name]
  }
}

# Create the instance that would run the ELK stack
resource "aws_instance" "elk" {
  ami = data.aws_ami.elk.id
  # So won't slow down and crash from data input
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.elk.id]
  # assumes that elk key has been created beforehand on this account in this region
  key_name = "elk"
  # Don't need this since Ansible sorted this out in the image building process
  # user_data = 
  # When get time, add an IAM instance profile so that can use cloud watch (once created)
  # iam_instance_profile = 

  tags = {
    Name = "ELK"
  }

  # So that an instance of ELK is always running
  lifecycle {
    create_before_destroy = true
  }
}


# Attach decent size volumes here and or S3 bucket for certain logs
