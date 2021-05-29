variable azure_subscription_id {
  type = string
  default = "00000000-0000-0000-0000-000000000000"
}

variable rg_name {
    type = string
    default = "hot-girl-shit"
}

variable rg_region {
  type = string
  default = "eastus"
}

variable vm_size {
    type = string
    default = "Standard_B1ls"
}

variable username {
    type = string
    default = "hot-girl"
}

variable worker_count {
    type = number
    default = 3
}