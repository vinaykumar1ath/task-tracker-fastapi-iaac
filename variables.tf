variable "backend" {
  type = object({
    bucket = string 
    key    = string
    region = string
  })
  sensitive = false
}

variable "project" {
  type = object({
    region = string
    name   = string
    root_domain_name = string
  })
}

variable "task_tracker_fastapi_env" {
  type = object({
    DB_URL = string
    JWT_SECRET = string
  })
  sensitive = true
}
