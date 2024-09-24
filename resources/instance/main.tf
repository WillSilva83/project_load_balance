
## SECURITYS GROUP 
resource "aws_security_group" "sg_main" {
  name        = "sg_instance"
  description = "Security Group."
  vpc_id      = aws_vpc.vpc_main.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "terraform-sg-main"
  }

}


## TEMPLATE 
resource "aws_launch_template" "templante_instance" {
  name_prefix   = "instance-"
  image_id      = "ami-09523541dfaa61c85"
  instance_type = "t3.micro"

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "terraform-launch-template-instance"
    }
  }

  monitoring {
    enabled = true
  }
  lifecycle {
    create_before_destroy = true
  }

  user_data = filebase64("app.sh")

}



#AUTOSCALING GROUP 
resource "aws_autoscaling_group" "asg_instance" {

  launch_template {
    id      = aws_launch_template.templante_instance.id
    version = "$Latest"
  }
  min_size = 2
  max_size = 4

  vpc_zone_identifier = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  target_group_arns = ["${aws_lb_target_group.lb_tg.arn}"]
  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "terraform-asg-instace"
    propagate_at_launch = true
  }
}


#ELB 
resource "aws_lb" "lb_instance" {
  name               = "lb-instances"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.sg_main.id}"]
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  enable_deletion_protection = false

}

## TARGET GRUOUP 
resource "aws_lb_target_group" "lb_tg" {
  name     = "lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_main.id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2

  }

  tags = {
    Name = "lb-tg-terraform"
  }

}



## LISTENER 
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb_instance.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

## ASSOCIACAO AUTO SCALING GROUP -> TARGET GROUP 
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg_instance.name
  lb_target_group_arn    = aws_lb_target_group.lb_tg.arn

}


## OUTPUTS 
output "public_ip" {
  value = aws_lb.lb_instance.dns_name

}