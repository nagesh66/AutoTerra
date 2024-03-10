terraform {
  required_version = ">= 1.2.0"
  backend "gcs" {
    bucket = "auto-tera-state1232311"
  }
}
