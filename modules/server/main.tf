resource "aws_security_group" "app-sg"{

name = "Myapp-sg"
vpc_id=var.vpc_id

ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks= [var.my_ip]
}
ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks= ["0.0.0.0/0"]
}
egress {
from_port= 0
to_port = 0
protocol = "-1"
cidr_blocks= ["0.0.0.0/0"]
prefix_list_ids = []

}
tags = {

    Name = "${var.envi}-SG"
}
}

data "aws_ami" "amazon-linux-image" {

most_recent = true
owners = ["amazon"]
filter {
    name = "name"
    values = ["amzn2-ami-*-x86_64-gp2"]
}
filter{
name = "virtualization-type"
values = ["hvm"]

}
}

resource "aws_instance" "myapp-server"{

    ami = data.aws_ami.amazon-linux-image.id
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    vpc_security_group_ids=[aws_security_group.app-sg.id]
    availability_zone = var.avil_zone
    associate_public_ip_address= true
    key_name = aws_key_pair.ssh-key.key_name
    # user_data =file("UserData.sh")

root_block_device {
    volume_size = 8  # Size in GB
    volume_type = "gp2" # General Purpose SSD
  }
    tags = { 
        Name = "${var.envi}-server"
    }
    
}

resource "aws_key_pair" "ssh-key" {
key_name = "appkey"
public_key = file(var.public_key_location)
}
output "instance_id" {
  value = aws_instance.myapp-server.id  # Ensure this references the correct instance resource
}

# Create an EBS Volume
resource "aws_ebs_volume" "my_volume" {
  availability_zone = "us-east-1b"  # Ensure this matches your instance's AZ
  size         = 8
    tags = {
    Name = "my_ebs_volume"
  }
}
resource "aws_volume_attachment" "my_volume_attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.my_volume.id
  instance_id = aws_instance.myapp-server.id  # Correctly reference the output from the module
}
