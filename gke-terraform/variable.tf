variable "project" {
  description = "this is gcp project-id"
  type        = string
  default     = "rock-loop-449918-b0"
}

variable "region" {
  description = "this is gcp region"
  type        = string
  default     = "africa-south1"
}

variable "zone" {
  description = "this is gcp zone"
  type        = string
  default     = "africa-south1-a"
}

variable "K8s_version" {
  description = "this is the gke version"
  type        = string
  default     = "1.31.6-gke.1020000"
}
