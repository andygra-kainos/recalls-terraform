# AWS S3 assets Bucket
#
# Team-G backlog story BL-8658 requirements
# The data source bucket shall
# - be available per environment with name uk.gov.dvsa.recalls.${env}.assets
# - be versioning enabled
# - be MFA Delete–enabled
# - direct access logs to uk.gov.dvsa.recalls.${env}.assets.accesslogs bucket with retention of 7 days.

# TODO - hardcoded - parameterize via tf_vars.tf
resource "aws_s3_bucket" "uk_gov_dvsa_recalls_dev_assets_accesslogs" {
  # - have direct access logs to uk.gov.dvsa.recalls.${env}.assets.accesslogs with 30 days retention
  bucket  = "uk-gov-dvsa-recalls-dev-assets-accesslogs"
  region  = "eu-west-1"
  acl     = "log-delivery-write"
}

# - be available per environment with name uk.gov.dvsa.recalls.${env}.assets
resource "aws_s3_bucket" "uk_gov_dvsa_recalls_dev_assets" {
  bucket  = "uk-gov-dvsa-recalls-dev-assets"
  region  = "eu-west-1"
  acl     = "private"

  lifecycle_rule {
    # TODO - review - optional, do we need this?
    id      = "log"
    enabled = true

    prefix  = "log/"
    tags {
      "rule"      = "log"
      "autoclean" = "true"
    }

    # - have direct access logs to uk.gov.dvsa.recalls.${env}.assets.accesslogs with 30 days retention
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # TODO - what are the service retention requirements?
    # TODO - is this adequately satisfied by the above transition?
    # - have direct access logs to uk.gov.dvsa.recalls.${env}.assets.accesslogs with 30 days retention
    expiration {
      days = 90
    }
  }

  # - have direct access logs to uk.gov.dvsa.recalls.${env}.assets.accesslogs with 30 days retention
  logging {
    target_bucket = "${aws_s3_bucket.uk_gov_dvsa_recalls_dev_assets_accesslogs.id}"
    target_prefix = "log/"
  }

  # - have versioning enabled
  # - be MFA Delete–enabled
  versioning {
    enabled     = true
    mfa_delete  = false
  }
}

# In this instance, the data is the downloadable CSV file
# data "aws_s3_bucket_object" "dvsa-recalls-dataset" {
#   bucket = "${aws_s3_bucket.uk_gov_dvsa_recalls_dev_assets.id}"
#   key    = "assets/RecallsFile.csv"
#   # defaults to latest version
# }
