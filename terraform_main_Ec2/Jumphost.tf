#Create Jumphost Server(Means Main Server)
resource "aws_instance" "pavan" {
    ami = "ami-066784287e358dad1"
    instance_type = "t2.large"
    key_name = "Practice"
    subnet_id = aws_subnet.public-subnet-1.id
    vpc_security_group_ids = [aws_security_group.sg.id]
    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.instance-profile.name
    root_block_device {
      volume_size = 30
    }
    user_data = templatefile("./Install_tools.sh", {})

    tags = {
      Name = "Main-Project"
    }
    
}