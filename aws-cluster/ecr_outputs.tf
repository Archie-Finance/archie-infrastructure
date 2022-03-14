output "ecr_registry_arn" {
  description = "Container registry ARN"
  value       = resource.aws_ecr_repository.container_repository.arn
}
