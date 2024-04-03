//_____________________________________________________________________________________________
# Grupo de Segurança para Debian
resource "aws_security_group" "Debian_sg" {
 name        = "Debian-gs"
 description = "Allow SSH and Ping"
 vpc_id      = "vpc-0a6b73fda846f0561"

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
 }

 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
 }

 ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
 }

 ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Ping"
 }

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
}

//_____________________________________________________________________________________________

# Instância Debian com Docker
resource "aws_instance" "Debian_Ansible" {
 ami                         = "ami-058bd2d568351da34" # Substitua pelo ID da AMI do Debian
 instance_type               = "t2.micro"
 subnet_id                   = "subnet-0d823ddb2dcf69349" # Altere conforme necessário
 key_name                    = "terraform" # Altere conforme necessário
 associate_public_ip_address = true
 vpc_security_group_ids      = [aws_security_group.Debian_sg.id]

 user_data = <<-EOF
              #!/bin/bash
               # Atualiza a lista de pacotes
               apt-get update

               # Instala o git
               apt-get install -y git

               # Instala o Python 3.9
               apt-get install -y python3.9

               # Instala o pip para Python 3
               apt-get install -y python3-pip

               # Atualiza o pip
               pip3 install --upgrade pip

               # Instala o Ansible
               apt-get install -y ansible

               # Define o nome do host
               hostnamectl set-hostname srvansible

               #Atualizar nome 
               bash

               # Adiciona a linha ao arquivo /etc/apt/sources.list
               echo "deb http://deb.debian.org/debian/ bullseye main" >> /etc/apt/sources.list

               # Atualiza a lista de pacotes novamente
               apt update -y

               # Instala o Python 3.9 novamente (se necessário)
               apt install python3.9 -y

               # Configura o alias para python
               alias python=python3

               # Instala o pacote python-is-python3
               apt install python-is-python3 -y

               # Instala o pip para Python 3 novamente (se necessário)
               apt install python3-pip -y

               # Instala o Ansible novamente (se necessário)
               apt install ansible -y

               #Mudar senha do root
               echo -e "Info@134134\nInfo@134134" | passwd root

               # Descomenta e define PermitRootLogin como yes
               sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

               # Define PasswordAuthentication como yes
               sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

               # Reinicia o serviço SSH para aplicar as alterações
               systemctl restart ssh
              EOF

 tags = {
    Name = "AnsibleHost"
 }
}

//_____________________________________________________________________________________________

output "debian_ansible_instance_public_ip" {
 description = "IP Publico da Instancia EC2 Ansible"
 value       = aws_instance.Debian_Ansible.public_ip
}