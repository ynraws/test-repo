variable "project" {
  description = "this is gcp project-id"
  type        = string
  default     = "argon-zoo-454615-t9"
}

variable "region" {
  description = "this is gcp region"
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "this is gcp zone"
  type        = string
  default     = "asia-south1-a"
}

variable "K8s_version" {
  description = "this is the gke version"
  type        = string
  default     = "1.31.6-gke.1020000"
}

variable "node-count" {
  description = "this is the gke node count"
  type        = number
  default     = 2
}
