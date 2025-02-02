# Instance type
variable "instance_type" {
  default = {
    "clo835-assignment1" = "t3.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}

# Variable to signal the current environment 
variable "env" {
  default     = "clo835-assignment1"
  type        = string
  description = "Deployment Environment"
}




