output "bastion-ip-address" {
  value = aws_instance.bastion.public_ip
}

output "vpc_id" {
  value = aws_vpc.myvpc.id
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}