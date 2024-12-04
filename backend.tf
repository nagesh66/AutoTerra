terraform {
  required_version = ">= 1.2.0"
  backend "gcs" {
    bucket = "sachinsoni-sb-bucket-test-poc"
  }
}
#auto-tera-state1232311
