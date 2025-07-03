# Test file for locals block logic validation in main.tf
# Focus: Testing user list-to-map transformation and role mapping

# Mock provider for Datadog data sources
mock_provider "datadog" {
  mock_data "datadog_role" {
    defaults = {
      id = "mock-role-id"
    }
  }
}

# Test 1: Basic users list-to-map transformation
run "test_users_list_to_map_transformation" {
  command = plan

  variables {
    users = [
      {
        username             = "johndoe"
        email               = "john.doe@example.com"
        name                = "John Doe"
        roles               = ["standard"]
        disabled            = false
        send_user_invitation = true
      },
      {
        username             = "janesmith"
        email               = "jane.smith@example.com"
        name                = "Jane Smith"
        roles               = ["admin", "read_only"]
        disabled            = false
        send_user_invitation = true
      }
    ]
  }

  assert {
    condition = length(local.users) == 2
    error_message = "Users map should contain exactly 2 users"
  }

  assert {
    condition = contains(keys(local.users), "johndoe")
    error_message = "Users map should contain key 'johndoe'"
  }

  assert {
    condition = contains(keys(local.users), "janesmith")
    error_message = "Users map should contain key 'janesmith'"
  }

  assert {
    condition = local.users["johndoe"].email == "john.doe@example.com"
    error_message = "User johndoe should have correct email address"
  }

  assert {
    condition = local.users["janesmith"].name == "Jane Smith"
    error_message = "User janesmith should have correct name"
  }
}

# Test 2: Roles mapping and data source integration
run "test_roles_mapping_logic" {
  command = plan

  variables {
    users = [
      {
        username             = "testuser"
        email               = "test@example.com"
        name                = "Test User"
        roles               = ["standard"]
        disabled            = false
        send_user_invitation = true
      }
    ]
  }

  assert {
    condition = length(local.roles) == 3
    error_message = "Roles map should contain exactly 3 role mappings"
  }

  assert {
    condition = contains(keys(local.roles), "standard")
    error_message = "Roles map should contain 'standard' key"
  }

  assert {
    condition = contains(keys(local.roles), "admin")
    error_message = "Roles map should contain 'admin' key"
  }

  assert {
    condition = contains(keys(local.roles), "read_only")
    error_message = "Roles map should contain 'read_only' key"
  }

  assert {
    condition = local.roles["standard"] == data.datadog_role.standard.id
    error_message = "Standard role should map to correct data source ID"
  }

  assert {
    condition = local.roles["admin"] == data.datadog_role.admin.id
    error_message = "Admin role should map to correct data source ID"
  }

  assert {
    condition = local.roles["read_only"] == data.datadog_role.read_only.id
    error_message = "Read-only role should map to correct data source ID"
  }
}

# Test 3: Edge cases - empty users list and unique usernames
run "test_edge_cases_empty_users_and_uniqueness" {
  command = plan

  variables {
    users = []
  }

  assert {
    condition = length(local.users) == 0
    error_message = "Empty users list should result in empty users map"
  }

  assert {
    condition = length(local.roles) == 3
    error_message = "Roles map should still contain 3 mappings even with empty users"
  }
}

# Test 4: Multiple users with different role combinations
run "test_multiple_users_different_roles" {
  command = plan

  variables {
    users = [
      {
        username             = "admin_user"
        email               = "admin@example.com"
        name                = "Admin User"
        roles               = ["admin"]
        disabled            = false
        send_user_invitation = true
      },
      {
        username             = "readonly_user"
        email               = "readonly@example.com"
        name                = "Read Only User"
        roles               = ["read_only"]
        disabled            = true
        send_user_invitation = false
      },
      {
        username             = "multi_role_user"
        email               = "multi@example.com"
        name                = "Multi Role User"
        roles               = ["standard", "admin"]
        disabled            = false
        send_user_invitation = true
      }
    ]
  }

  assert {
    condition = length(local.users) == 3
    error_message = "Users map should contain exactly 3 users"
  }

  assert {
    condition = length(distinct(keys(local.users))) == length(keys(local.users))
    error_message = "All user keys should be unique (no duplicate usernames)"
  }

  assert {
    condition = local.users["admin_user"].roles == toset(["admin"])
    error_message = "Admin user should have correct roles"
  }

  assert {
    condition = local.users["readonly_user"].disabled == true
    error_message = "Read-only user should be disabled"
  }

  assert {
    condition = local.users["multi_role_user"].roles == toset(["standard", "admin"])
    error_message = "Multi-role user should have correct roles set"
  }
}
