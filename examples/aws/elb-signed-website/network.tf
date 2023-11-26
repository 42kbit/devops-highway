
# will create default vpc if not pressent,
# also allows explicit reference to it, which is prefered.
resource "aws_default_vpc" "default" {}

# select all avail zones from default vpc
data "aws_availability_zones" "all" {}

# select all default subnets from all avail zones
data "aws_subnet" "all_defaults" {
  count             = length(data.aws_availability_zones.all.names)
  availability_zone = data.aws_availability_zones.all.names[count.index]
  default_for_az    = true
}
