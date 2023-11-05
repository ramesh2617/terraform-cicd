resource "aws_instance" "my_vm" {
 ami                       = "ami-0f5ee92e2d63afc18" //Ubuntu AMI
 instance_type             = "t2.micro"
}
