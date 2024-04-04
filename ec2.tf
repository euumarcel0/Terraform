//_____________________________________________________________________________________________
# Grupo de Segurança para Windows
resource "aws_security_group" "Windows_sg" {
 name        = "Windows-gs"
 description = "Allow RDP and Ping"
 vpc_id      = aws_vpc.VPC-CloudPlay.id

 ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "RDP"
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

data "template_file" "user_data_windows" {
  template = file("C:/Users/46683590842/Documents/Terraform-VS/Scripts/windows.ps1")
}

# Instância Windows
resource "aws_instance" "Windows" {
  ami                         = "ami-03cd80cfebcbb4481"
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.Subrede-Pub1.id
  key_name                    = "windows"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.Windows_sg.id]
  user_data                   = base64encode(data.template_file.user_data_windows.rendered)
  get_password_data           = "true"

  tags = {
    Name = "Windows-TerraServidor"
  }
}

output "IP-Windows" {
 description = "IP Publico da Instancia EC2 Windows"
 value       = aws_instance.Windows.public_ip
}

output "Usuario-Windows" {
  description = "Usuário Windows"
  value       = "Administrator"
}

output "Senha-Windows" {
  description = "Senha Windows"
  value       = rsadecrypt(aws_instance.Windows.password_data, file("C:/Users/46683590842/Documents/Terraform-VS/chave/windows.pem"))
}