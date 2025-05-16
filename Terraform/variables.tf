# GCP Project ID
variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "copper-cider-453013-b7"
}

# GCP Region
variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "us-central1"
}

# GCP Zone
variable "zone" {
  description = "The GCP zone to deploy instances"
  type        = string
  default     = "us-central1-a"
}

# Machine Type
variable "machine_type" {
  description = "GCP Compute Engine machine type"
  type        = string
  default     = "e2-medium"
}

# Instance Template Name Prefix
variable "instance_template_prefix" {
  description = "Prefix for the instance template name"
  type        = string
  default     = "apache-template"
}

# Base Instance Name
variable "base_instance_name" {
  description = "Base name for VM instances in the group"
  type        = string
  default     = "apache-instance"
}

# Target Size of MIG
variable "target_size" {
  description = "Initial number of instances in MIG"
  type        = number
  default     = 2
}
