variable "region" {
  description = "specified aws region"
  default     = "us-east-1"
}


variable "cidr_block" {
  description = "value of vpc"
  default     = "10.0.0.0/16"
}

variable "key_pair" {
  description = "value of my keypair"
  default     = "ConnectSSH"
}

variable "my_ip" {
  description = "value of my own ip"
  default     = "102.88.113.174/32"

}

variable "instance_type_web" {
  description = "web_instance"
  default     = "t3.micro"
}

variable "instance_type_database" {
  description = "value of database_instance"
  default     = "t3.small"
}
variable "ami_value" {
  description = "value for ami"
  default     = "ami-0fa3fe0fa7920f68e"
}

