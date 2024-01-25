

########################### creating a iam policy################
resource "aws_iam_policy" "policy" {
  name        = "s3full"
  path        = "/"
  description = "My test policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
############################ creating a iam role############
resource "aws_iam_role" "test_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

############################### role attachment to policy #############################
 
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = aws_iam_policy.policy.arn
}


################# instance profile from role
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.test_role.name
}
############ creating a instance and attaching iam role from instance profile##########

resource "aws_instance" "foo" {
  ami           = "ami-03f4878755434977f" # ap-south-1
  instance_type = "t2.micro"
  subnet_id = "subnet-0d0db1c9229bd320d"
  key_name = "ssh-key-jenkins"
  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  tags = {
    Name = "terraforminstance"
  }

   root_block_device {
     delete_on_termination = true
     encrypted             = false
     volume_size           = 10
     volume_type           = "gp2"
   }


}
