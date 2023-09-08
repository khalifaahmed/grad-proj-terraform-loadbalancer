variable "vpc_cidr" {
  type = string
}
variable "name" {
  type = string
}

# variable "public_subnet_count" {
#   type        = number
#   description = "at least 3 as number of az = 3"
# }
# variable "private_subnet_count" {
#   type = number
# }

# variable "public_cidrs" {
#   type = list
#   default = [for i in range(1, 255, 2) : cidrsubnet("10.0.0.0/16", 8, i)]
# }
# variable "private_cidrs" {
#   type = list
# }
#variable will not be working as variable do not accept fuctions inside them man 


variable "access_ip_v4" {
  type = string
}

variable "access_ip_v6" {
  type = string
}

variable "db_subnet_group" {
  type = bool
}

variable "db_instance" {
  type = bool
}

# variable "public1_subnet_cidr" {
#   type = string
# }
# variable "public2_subnet_cidr" {
#   type = string
# }
# variable "public3_subnet_cidr" {
#   type = string
# }
# variable "private1_subnet_cidr" {
#   type = string
# }
# variable "private2_subnet_cidr" {
#   type = string
# }
# variable "private3_subnet_cidr" {
#   type = string
# }
# variable "az1" {
#   type = string
# }
# variable "az2" {
#   type = string
# }
# variable "az3" {
#   type = string
# }
variable "provider_region" {
  type        = string
  default     = ""
  description = "description"
}
variable "ec2_count" {
  type = number
}
variable "instance_type" {
  type    = string
  default = ""
}
variable "key" {
  type        = string
  default     = ""
  description = "description"
}

# variable "max_subnets" {
#   type        = number
#   default     = 3
#   description = "the upper limit of the number of public subnets or private subnets separatedly, it will overwrite the public_subnet_count or private_subnet_count variables man"
# }


locals {
  public_subnet_count  = length(data.aws_availability_zones.available.names)
  private_subnet_count = length(data.aws_availability_zones.available.names)
  max_subnets          = length(data.aws_availability_zones.available.names) * 5
  public_cidrs         = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_cidrs        = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}


locals {
  security_groups = {
    ssh = {
      name        = "grad-proj-ssh-sg"
      description = "security group for public access"
      ingress = {
        ssh = {
          description      = "allow ssh from our access ip only"
          from             = 22
          to               = 22
          protocol         = "tcp"
          cidr_blocks      = [var.access_ip_v4]
          ipv6_cidr_blocks = [var.access_ip_v6]
        }
      }
    }
    http_https = {
      name        = "grad-proj-http-https-sg"
      description = "security group for public access"
      ingress = {
        http = {
          description      = "allow http traffic from anywhere"
          from             = 80
          to               = 80
          protocol         = "tcp"
          cidr_blocks      = ["0.0.0.0/0"]
          ipv6_cidr_blocks = ["::/0"]
        }
        https = {
          description      = "allow https traffic from anywhere"
          from             = 443
          to               = 443
          protocol         = "tcp"
          cidr_blocks      = ["0.0.0.0/0"]
          ipv6_cidr_blocks = ["::/0"]
        }
      }
    }
    rds = {
      name        = "grad-proj-rds-sg"
      description = "security group for rds"
      ingress = {
        postgres = {
          description      = "allow postgres sql traffic"
          from             = 5432
          to               = 5432
          protocol         = "tcp"
          cidr_blocks      = [var.access_ip_v4]
          ipv6_cidr_blocks = [var.access_ip_v6]
        }
      }
    }
    public = {
      name        = "grad-proj-public-sg"
      description = "security group for public access"
      ingress = {
        public = {
          description      = "allow all traffic from our access ip only"
          from             = 0
          to               = 0
          protocol         = "-1"
          cidr_blocks      = [var.access_ip_v4]
          ipv6_cidr_blocks = [var.access_ip_v6]
        }
      }
    }
  }
}

