
variable "environments" {
  description = "List of environments to create variable groups for"
  type        = list(string)
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}
