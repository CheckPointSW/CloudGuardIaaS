output "internal_default_route_id" {
  value = aws_route.internal_default_route.*.id
}