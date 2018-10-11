# AWS S3 Datasource Bucket
#
# Team-G backlog story BL-8659 requirements
# The data source bucket shall
# - be available per environment with name uk.gov.dvsa.recalls.${env}.datasource
# - have versioning enabled
# - be MFA Delete–enabled
# - have direct access logs to uk.gov.dvsa.recalls.${env}.datasource.accesslogs with 30 days retention
# - rely on role-based access to only allow Frontend Lambda to read the data from it i.e. define bucket policy to allow Frontend Lambda specific role to read from this bucket and allow Frontend Lambda to talk to the bucket uk.gov.dvsa.recalls.${env}.datasource
# - be populated with data file fetched from git repository: https://github.com/dvsa/recalls-datasource

# TODO - hardcoded - parameterize via tf_vars.tf
resource "aws_s3_bucket" "uk_gov_dvsa_recalls_dev_datasource_accesslogs" {
  # - have direct access logs to uk.gov.dvsa.recalls.${env}.datasource.accesslogs with 30 days retention
  bucket  = "uk-gov-dvsa-recalls-dev-datasource-accesslogs"
  region  = "eu-west-1"
  acl     = "log-delivery-write"
}

# - be available per environment with name uk.gov.dvsa.recalls.${env}.datasource
resource "aws_s3_bucket" "uk_gov_dvsa_recalls_dev_datasource" {
  bucket  = "uk.gov.dvsa.recalls.dev.datasource"
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

    # - have direct access logs to uk.gov.dvsa.recalls.${env}.datasource.accesslogs with 30 days retention
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # TODO - what are the service retention requirements?
    # TODO - is this adequately satisfied by the above transition?
    # - have direct access logs to uk.gov.dvsa.recalls.${env}.datasource.accesslogs with 30 days retention
    expiration {
      days = 90
    }
  }

  # - have direct access logs to uk.gov.dvsa.recalls.${env}.datasource.accesslogs with 30 days retention
  logging {
    target_bucket = "${aws_s3_bucket.uk_gov_dvsa_recalls_dev_datasource_accesslogs.id}"
    target_prefix = "log/"
  }

  # - have versioning enabled
  # - be MFA Delete–enabled
  versioning {
    enabled     = true
    mfa_delete  = false
  }
}
