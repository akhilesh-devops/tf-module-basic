resource "aws_instance" "instances" {
  ami                     = data.aws_ami.ami.id
  vpc_security_group_ids  = var.vpc_security_group_ids
  instance_type           = var.instance_type

  tags = {
    Name = var.name
  }
}

resource "aws_route53_record" "record" {
  zone_id = var.zone_id
  name    = "${var.name}-dev.vinithaws.online"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instances.private_ip]
}

resource "null_resource" "ansible" {

  depends_on = [
    aws_route53_record.record
  ]

  provisioner "local-exec" {
    command = <<EOF
cd /home/centos/roboshop-ansible
git pull
sleep 30
ansible-playbook -i ${var.name}-dev.vinithaws.online, main.yml -e ansible_user=centos -e ansible_password=DevOps321 -e component=${var.name}
EOF
  }
}