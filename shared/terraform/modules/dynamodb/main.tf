module "iam_policy_dynamodb_read_write" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "4.14.0"

  name        = "DynamoDBReadWriteAccess"
  path        = "/"
  description = "Access to DynamoDB reads and writes"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:DescribeImport",
                "dynamodb:DescribeContributorInsights",
                "dynamodb:ListTagsOfResource",
                "dynamodb:DescribeReservedCapacityOfferings",
                "dynamodb:PartiQLSelect",
                "dynamodb:DescribeTable",
                "dynamodb:GetItem",
                "dynamodb:DescribeContinuousBackups",
                "dynamodb:DescribeExport",
                "dynamodb:DescribeKinesisStreamingDestination",
                "dynamodb:DescribeLimits",
                "dynamodb:BatchGetItem",
                "dynamodb:ConditionCheckItem",
                "dynamodb:PutItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:ListStreams",
                "dynamodb:DescribeGlobalTableSettings",
                "dynamodb:GetShardIterator",
                "dynamodb:DescribeGlobalTable",
                "dynamodb:DescribeReservedCapacity",
                "dynamodb:DescribeBackup",
                "dynamodb:GetRecords",
                "dynamodb:DescribeTableReplicaAutoScaling"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

module "iam_user_dynamodb_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "4.14.0"

  name = "DynamoDBAccess"
}

resource "aws_iam_user_policy_attachment" "attach_dynamodb_read_write_access_policy" {
  user       = module.iam_user_dynamodb_access.iam_user_name
  policy_arn = module.iam_policy_dynamodb_read_write.arn
}

module "event_idempotency_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "event-idempotency-table"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]
}