terraform {
  required_version = "~> 1.5"

  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = "~> 3.14"
    }
  }
}
