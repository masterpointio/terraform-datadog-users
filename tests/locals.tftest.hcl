# Tests for locals block logic in main.tf
# Focus: User list-to-map transformation and role mapping

mock_provider "datadog" {
  mock_data "datadog_role" {
    defaults = {
      id = "mock-role-id"
    }
  }
}

# Test 1: User list-to-map transformation with single user
run "test_single_user_transformation" {
  command = plan

  variables {
    users = [
      {
        username             = "john.doe"
        email                = "john.doe@example.com"
        name                 = "John Doe"
        roles                = ["standard"]
        disabled             = false
        send_user_invitation = true
      }
    ]
  }

  assert {
    condition     = contains(keys(local.users), "john.doe")
    error_message = "Map should be keyed by username 'john.doe'"
  }

  assert {
    condition     = local.users["john.doe"].email == "john.doe@example.com"
    error_message = "User email should be preserved in transformation"
  }

  assert {
    condition     = local.users["john.doe"].name == "John Doe"
    error_message = "User name should be preserved in transformation"
  }
}

# Test 2: Role mapping logic
run "test_role_mapping_logic" {
  command = plan

  variables {
    users = [
      {
        username             = "admin.user"
        email                = "admin@example.com"
        name                 = "Admin User"
        roles                = ["admin"]
        disabled             = false
        send_user_invitation = true
      }
    ]
  }

  assert {
    condition     = local.roles["standard"] == "mock-role-id"
    error_message = "Standard role should map to mock role ID"
  }

  assert {
    condition     = local.roles["admin"] == "mock-role-id"
    error_message = "Admin role should map to mock role ID"
  }

  assert {
    condition     = local.roles["read_only"] == "mock-role-id"
    error_message = "Read only role should map to mock role ID"
  }

  assert {
    condition     = length(keys(local.roles)) == 3
    error_message = "Should have exactly 3 role mappings"
  }
}

# Test 3: Multiple users with mixed roles transformation
run "test_multiple_users_mixed_roles" {
  command = plan

  variables {
    users = [
      {
        username             = "alice.admin"
        email                = "alice@example.com"
        name                 = "Alice Admin"
        roles                = ["admin", "standard"]
        disabled             = false
        send_user_invitation = true
      },
      {
        username             = "bob.readonly"
        email                = "bob@example.com"
        name                 = "Bob ReadOnly"
        roles                = ["read_only"]
        disabled             = true
        send_user_invitation = false
      },
      {
        username             = "charlie.standard"
        email                = "charlie@example.com"
        name                 = "Charlie Standard"
        roles                = ["standard"]
        disabled             = false
        send_user_invitation = true
      }
    ]
  }

  assert {
    condition     = length(local.users) == 3
    error_message = "Should transform three users into map with three entries"
  }

  assert {
    condition     = (
      contains(keys(local.users), "alice.admin")
      && contains(keys(local.users), "bob.readonly")
      && contains(keys(local.users), "charlie.standard")
    )
    error_message = "Map should contain all three usernames as keys"
  }

  assert {
    condition     = (local.users["alice.admin"].disabled == false
                    && local.users["bob.readonly"].disabled == true)
    error_message = "User disabled status should be preserved in transformation"
  }

  assert {
    condition     = (
      contains(local.users["alice.admin"].roles, "admin")
      && contains(local.users["alice.admin"].roles, "standard")
    )
    error_message = "Alice should have both admin and standard roles preserved"
  }

  assert {
    condition     = (
      length(local.users["bob.readonly"].roles) == 1
      && contains(local.users["bob.readonly"].roles, "read_only")
    )
    error_message = "Bob should have only read_only role preserved"
  }
}
