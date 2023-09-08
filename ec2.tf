# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# EC2 Instance
resource "aws_instance" "myec2" {
  ami                         = data.aws_ami.amzlinux2.id
  instance_type               = var.instance_type
  user_data                   = file("${path.module}/app1-install.sh")
  key_name                    = var.key
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.grad_proj_sg["ssh"].id, aws_security_group.grad_proj_sg["http_https"].id, aws_security_group.grad_proj_sg["public"].id]
  count                       = var.ec2_count
  tags = {
    "Name" = "${var.name}_ec2"
  }

  provisioner "local-exec" {
    working_dir = "./ec2-docker"
    #command     = "export db_url=${aws_db_instance.grad_proj_db[0].endpoint} ; envsubst < docker-compose-vars.yaml > docker-compose-gp.yaml; ansible-playbook --inventory ${self.public_ip}, --user ec2-user --private-key /home/ahmed/Desktop/ansible/ec2-docker/terraform_key_pair.pem  deploy-docker.yaml"
    command = "ssh-keyscan -H ${self.public_ip} >> /home/ahmed/.ssh/known_hosts ; ansible-playbook --inventory ${self.public_ip}, --user ec2-user --private-key /home/ahmed/Desktop/stockholm_key.pem  deploy-docker.yaml"
  }
}


resource "aws_ami_from_instance" "example" {
  name               = "grad-proj-AMI"
  source_instance_id = aws_instance.myec2[0].id
  
  # After we create our golden AMI --> we terminate the ec2 from which we had create our golden AMI
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.myec2[0].id} --region ${var.provider_region}"
  }
}


#   provisioner "local-exec" {
#     working_dir = "./redhat"
#     command = "ansible-playbook --inventory ${self.public_ip}, --user ec2-user --private-key /home/ahmed/Desktop/ansible/ec2-docker/terraform_key_pair.pem  deploy_httpd.yaml"
#     #command = "export cont_name""=${self.public_ip} ; envsubst < docker-compose.yaml > outofenvsubst2"
#     #command = "export cont_name=${data.aws_ami.ubuntu_ami.id} ; envsubst < docker-compose.yaml > outofenvsubst3"
#     #command = "envsubst < docker-compose.yaml > outofenvsubst2"
#     #command = "ansible-playbook --inventory ${self.public_ip}, --user ubuntu --private-key /home/ahmed/Desktop/ansible/ec2-docker/terraform_key_pair.pem deploy-nexus.yaml"
#   }

