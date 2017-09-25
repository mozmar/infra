provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "mdn-cdn-provisioning-tf-state"
    key    = "tf-state"
    region = "us-west-2"
  }
}


module "mdn-cloudfront-stage" {
    source = "./cloudfront"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/f46733a9-d662-4cb4-b344-b09c8a5cb624"
    aliases = ["stage-cdn.mdn.mozilla.net", "stage-cdn.mdn.moz.works"]
    comment = "Stage CDN for AWS-hosted MDN"
    distribution_name = "MDNStageCDN"
    domain_name = "developer.allizom.org"
}

module "mdn-cloudfront-prod" {
    source = "./cloudfront"

    acm_cert_arn = "arn:aws:acm:us-east-1:236517346949:certificate/8f9e3e77-984b-4e1d-92c6-214e79435df3"
    aliases = ["cdn.mdn.mozilla.net", "cdn.mdn.moz.works"]
    comment = "Prod CDN for AWS-hosted MDN"
    distribution_name = "MDNProdCDN"
    domain_name = "developer.mozilla.org"
}


