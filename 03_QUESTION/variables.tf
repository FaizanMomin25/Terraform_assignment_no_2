variable "cidr_block" {
  type = string
}

variable "public_cidr_block" {
  type = list(string)
}

variable "private_cidr_block" {
  type = list(string)
}
variable "availability_zone" {
  type = list(string)
}

variable "ingress_rules" {
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = {
    http = {
      description = "Allow HTTP traffic"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    },
    https = {
      description = "Allow HTTPS traffic"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
    }
  }
}

//FOR SSH 

variable "ssh_key_name" {
  type = string
}
variable "ssh_public_key_path" {
  type = string
}

//FOR ALB 

variable "lb_name" {
  type = string
}

variable "lb_type" {
  type = string
}

