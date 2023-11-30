
resource "aws_default_vpc" "default" {}

data "aws_availability_zones" "all" {}

data "aws_subnet" "all_defaults" {
  count             = length(data.aws_availability_zones.all.names)
  availability_zone = data.aws_availability_zones.all.names[count.index]
  default_for_az    = true
}
