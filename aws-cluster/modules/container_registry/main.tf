resource "aws_ecr_repository" "container_repository" {
  name = "${var.name}-container-repository"

  image_tag_mutability = "IMMUTABLE"
}