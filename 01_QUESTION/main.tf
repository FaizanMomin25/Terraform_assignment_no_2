resource "aws_iam_group" "this_iam_group" {
  name = "dev_${count.index}"
  count = 3
}

resource "aws_iam_user" "this_iam_user" {
  name = "faizan_${count.index}"
  count = 3
}

resource "aws_iam_group_membership" "this_iam_group_membership" {
  name = "dev_${count.index}_membership"
  count = 3

  users = [
    aws_iam_user.this_iam_user[count.index].name,
  ]
  group = aws_iam_group.this_iam_group[count.index].name 
}