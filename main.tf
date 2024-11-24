resource "google_storage_bucket" "auto-expire" {
  name          = "no-public-access-bucket-22324ss242g"
  location      = "US"
  force_destroy = true
}



resource "google_compute_instance" "my_instance" {
  name         = "my-instance1"
  machine_type = "n1-standard-1"
  project      = "nagesh-sandbox"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
  }
}
