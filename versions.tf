terraform {
  required_version = ">= 1.3"

  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = ">= 4.0"
    }
  }
}
