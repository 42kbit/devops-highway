
resource "aws_autoscaling_group" "main" {
  # min_size and min_elb_capacity should match to avoid undefined behavior.
  # (and, you know, common sense).
  name = "asg-main"

  min_size                  = 1 # min number of instances that always should be up
  max_size                  = 2
  desired_capacity          = 2
  min_elb_capacity          = 1 # min number that should be registered within ELB
  health_check_grace_period = 300
  health_check_type         = "ELB"

  force_delete = true
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  vpc_zone_identifier = [for subnet in data.aws_subnet.all_defaults : subnet.id]
  load_balancers      = [aws_elb.main.name]

  lifecycle {
    replace_triggered_by = [aws_launch_template.main] # renew after new template
  }
  # this line is redundant, but helps to understand the order out of chaos 
  # resourse creation process might be.
  depends_on = [aws_launch_template.main] # create new only after template update
}
