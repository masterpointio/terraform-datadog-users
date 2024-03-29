users = [
  {
    roles    = ["standard"],
    email    = "john.doe@example.com",
    name     = "John Doe",
    role     = "Administrator",
    username = "johndoe"
  },
  {
    roles    = ["read_only"],
    email    = "jane.smith@example.com",
    name     = "Jane Smith",
    role     = "Editor",
    username = "janesmith"
  }
]

secret_mapping = [
  {
    name = "datadog_api_key"
    file = "example.yaml"
    type = "sops"
  },
  {
    name = "datadog_app_key"
    file = "example.yaml"
    type = "sops"
  }
]
