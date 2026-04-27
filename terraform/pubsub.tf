resource "google_pubsub_topic" "realtime_topic" {
  name = "realtime-topic"
}

resource "google_pubsub_topic" "dead_letter_topic" {
  name = "dead-letter-topic"
}

resource "google_pubsub_subscription" "realtime_sub" {
  name  = "realtime-sub"
  topic = google_pubsub_topic.realtime_topic.name

  ack_deadline_seconds = 20

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter_topic.id
    max_delivery_attempts = 5
  }
}