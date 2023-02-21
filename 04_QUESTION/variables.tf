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

//FOR APP SG INGRESS RULES
variable "ingress_rules" {
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = {
    http = {
      description = "Allow ALL TCP traffic"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
    }
  }
}

//FOR RDS SG INGRESS RULES

variable "rds_ingress_rules" {
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = {
    http = {
      description = "Allow ALL TCP traffic"
      from_port   = 3306
      to_port     = 3306
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

variable "private_subnet_group_name" {
  type = string
}

//FOR DB INSTANCE

variable "identifier" {
  type = string
}

variable "db_name" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "username" {
  type = string
}

variable "port" {
  type = number
}

variable "backup_retention_period" {
  type = number
}