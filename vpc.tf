#VPC de AWS
resource "aws_vpc" "COURSE_VPC" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge({
      #genera una funcion para unir el nuevo tag a crear, adjuntamos todos los recursos.
      "Name" = "${local.name_prefix}-VPC" 
  },
  local.default_tags,
  )
}

#Internet Gateway
resource "aws_internet_gateway" "COURSE_IGW"{
    vpc_id = aws_vpc.COURSE_VPC.id
    tags = merge({
        "Name" = "${local.name_prefix}-IGW"
    },
    local.default_tags,
    )
}

#Subnet (SubRed publica)
resource "aws_subnet" "COURSE_PUBLIC_SUBNET"{
    map_public_ip_on_launch = true
    availability_zone = element(var.az_name, 0)
    vpc_id = aws_vpc.COURSE_VPC.id
    cidr_block = element(var.subnet_cidr_blocks, 0)
    tags = merge({
        "Name" = "${local.name_prefix}-SUBNET-AZ-A"
    },
    local.default_tags,
    )
}

#Subnet (SubRed Privada)
resource "aws_subnet" "COURSE_PRIVATE_SUBNET"{
    map_public_ip_on_launch = false
    availability_zone = element(var.az_name, 1)
    vpc_id = aws_vpc.COURSE_VPC.id
    cidr_block = element(var.subnet_cidr_blocks, 1)
    tags = merge({
        "Name" = "${local.name_prefix}-SUBNET-AZ-B"
    },
    local.default_tags,
    )
}

#Elastic IP
resource "aws_eip" "APP_EIP"{
}

#NAT GATEWAY
resource "aws_nat_gateway" "COURSE_NAT"{
    subnet_id = aws_subnet.COURSE_PUBLIC_SUBNET.id
    allocation_id = aws_eip.APP_EIP.id
    tags = merge({
        "Name" = "${local.name_prefix}-NGW"
    },
    local.default_tags,
    )
}

#Route table
resource "aws_route_table" "COURSE_PUBLIC_ROUTE"{
    vpc_id = aws_vpc.COURSE_VPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.COURSE_IGW.id
    }
    tags = merge({
        "Name" = "${local.name_prefix}-PUBLIC-RT"
    },
    local.default_tags,
    )
}