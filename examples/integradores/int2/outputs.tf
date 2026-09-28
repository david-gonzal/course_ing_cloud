output "ec2_primary_ip" {
  value       = aws_instance.k3s_node_r1.public_ip
  description = "IP Pública EC2 us-east-1"
}

output "rds_primary_endpoint" {
  value       = aws_db_instance.rds_primary.address
  description = "Endpoint DB Primaria"
}

output "ec2_secondary_ip" {
  value       = var.enable_drp_region2 ? aws_instance.k3s_node_r2[0].public_ip : "NO_DESPLEGADO"
  description = "IP Pública EC2 us-east-2"
}

output "rds_replica_endpoint" {
  value       = var.enable_drp_region2 ? aws_db_instance.rds_replica[0].address : "NO_DESPLEGADO"
  description = "Endpoint DB Secundaria"
}