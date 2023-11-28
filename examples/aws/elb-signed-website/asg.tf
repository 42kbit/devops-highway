
# not sure if there is an easier way
resource "random_uuid" "aws_asg_postfix" {
  lifecycle {
    # depends on the same thing as aws_autoscaling_group.main
    # it cannot depend directly on aws_autoscaling_group.main
    # because it would make circular dependency.
    replace_triggered_by = [aws_launch_template.main]
  }
}

resource "aws_autoscaling_group" "main" {
  # name should be unique
  name = "asg-main-${random_uuid.aws_asg_postfix.result}"

  # min_size and min_elb_capacity should match to avoid undefined behavior.
  # (and, you know, common sense).
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
  target_group_arns = [
    aws_alb_target_group.http80.arn,
  ]

  lifecycle {
    # lower dowitime, by creating new instances
    # before destroying old ones.
    create_before_destroy = true
    replace_triggered_by  = [aws_launch_template.main] # renew after new template
  }
  # this line is redundant, but helps to understand the order out of chaos 
  # resourse creation process might be.
  depends_on = [aws_launch_template.main] # create new only after template update
}
