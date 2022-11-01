# terraform {
#   backend "s3" {
#     bucket         = "friendshub-terraform-backend"
#     key            = "friendshub/ekamastate"
#     region         = "eu-west-3"
#     dynamodb_table = "friendshub-state-lock-table"

#   }
# }