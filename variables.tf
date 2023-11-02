variable "registry" {
  description = "contains container registry related configuration"
  type        = any
}

variable "naming" {
  description = "contains naming related configuration"
  type        = map(string)
  default     = {}
}
