variable "debian12" {
  type        = string
  default     = "debian-12"
  description = "debian12_name"
}

variable "centos9" {
  type        = string
  default     = "centos-stream-9-oslogin"
  description = "centos-stream-9-oslogin"
}

variable "centos8" {
  type        = string
  default     = "centos-stream-8"
  description = "centos-stream-8"
}

variable "nat-instance-ubuntu" {
  type        = string
  default     = "nat-instance-ubuntu"
  description = "nat-instance-ubuntu"
}


variable "yc_zone" {
  type        = string
  default     = "ru-central1-b"
  description = "zone datacenter"
}