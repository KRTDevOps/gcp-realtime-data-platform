resource "google_composer_environment" "composer_env" {
  name   = var.composer_env_name
  region = var.region

  config {
    node_count = 1

    software_config {
      image_version = var.composer_image_version
    }
  }
}