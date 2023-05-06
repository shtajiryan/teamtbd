terraform {
  backend "s3" {
    bucket         = "myterraform-1"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
# terraform {
#   backend "s3" {
#     bucket         = "myterraform-1"
#     key            = "global://s3/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#   }
# }