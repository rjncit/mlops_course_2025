resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "example" {
  bucket = "mlops-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
