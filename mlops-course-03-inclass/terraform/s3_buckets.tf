module "s3_bucket" {
  for_each = { for s3 in var.s3_buckets : s3.key => s3 }
  source   = "./modules/s3-bucket"

  bucket = each.value.key
  tags   = merge(try(each.value.tags, {}), { environment = var.environment })
}
