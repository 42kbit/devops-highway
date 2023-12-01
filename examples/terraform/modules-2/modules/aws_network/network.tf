
data "aws_availability_zones" "zones" {}

variable "vpc" {
  type = object({
    cidr_block = string
  })
}

variable "subnets" {
  type = list(object({
    cidr_block = string
    is_public  = bool
  }))
}

locals {
  public_subnets  = [for s in var.subnets : s if s.is_public == true]
  private_subnets = [for s in var.subnets : s if s.is_public == false]
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc.cidr_block
}

output "vpc_id" {
  value = aws_vpc.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public_to_gateway" {
  count          = length(local.public_subnets)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = aws_subnet.public[count.index].id
}

# Create public subnets
resource "aws_subnet" "public" {
  count = length(local.public_subnets)

  vpc_id = aws_vpc.main.id
  availability_zone_id = data.aws_availability_zones.zones.zone_ids[
    count.index % length(data.aws_availability_zones.zones.zone_ids)
  ]
  cidr_block              = local.public_subnets[count.index].cidr_block
  map_public_ip_on_launch = true

  # ipv6 can be later added like that (will require rewriting lots but still)
  # ipv6_cidr_block = can(local.subnets[count.index].ipv6_cidr_block) ? local.subnets[count.index].ipv6_cidr_block : null
}

output "public_subnets" {
  value = aws_subnet.public
}

resource "aws_subnet" "private" {
  count = length(local.private_subnets)

  vpc_id = aws_vpc.main.id
  availability_zone_id = data.aws_availability_zones.zones.zone_ids[
    count.index % length(data.aws_availability_zones.zones.zone_ids)
  ]
  cidr_block              = local.private_subnets[count.index].cidr_block
  map_public_ip_on_launch = false
}

output "private_subnets" {
  value = aws_subnet.private
}
