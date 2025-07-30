# Tests for main.tf resource creation and configuration
# Focus: datadog_user resource creation, attribute mapping, and for_each logic

mock_provider "datadog" {
  mock_data "datadog_role" {
    defaults = { id = "mock-role-id" }
  }
  mock_resource "datadog_user" {
    defaults = { id = "mock-user-id" }
  }
}

# Test 1: Basic single user resource creation and attributes
run "test_single_user_resource_creation" {
  command = plan

  variables {
    users = [{
      username = "john.doe", email = "john.doe@example.com", name = "John Doe"
      roles = ["standard"], disabled = false, send_user_invitation = true
    }]
  }

  assert {
    condition = length(keys(datadog_user.users)) == 1
    error_message = "Should create exactly one datadog_user resource"
  }

  assert {
    condition = contains(keys(datadog_user.users), "john.doe")
    error_message = "Resource key should match username 'john.doe'"
  }

  assert {
    condition = datadog_user.users["john.doe"].email == "john.doe@example.com"
    error_message = "User email should be correctly assigned to resource"
  }

  assert {
    condition = datadog_user.users["john.doe"].name == "John Doe"
    error_message = "User name should be correctly assigned to resource"
  }

  assert {
    condition = datadog_user.users["john.doe"].disabled == false
    error_message = "User disabled status should be correctly assigned"
  }

  assert {
    condition = datadog_user.users["john.doe"].send_user_invitation == true
    error_message = "User send_user_invitation should be correctly assigned"
  }

  assert {
    condition = length(datadog_user.users["john.doe"].roles) == 1
    error_message = "User should have exactly one role assigned"
  }

  assert {
    condition = contains(datadog_user.users["john.doe"].roles, "mock-role-id")
    error_message = "User role should be mapped to mock role ID"
  }
}

# Test 2: Multiple users with comprehensive configuration testing
run "test_multiple_users_comprehensive" {
  command = plan

  variables {
    users = [
      { username = "alice.admin", email = "alice@example.com", name = "Alice Admin",
        roles = ["admin", "standard"], disabled = false, send_user_invitation = true },
      { username = "bob.readonly", email = "bob@example.com", name = "Bob ReadOnly",
        roles = ["read_only"], disabled = true, send_user_invitation = false },
      { username = "user.with.dots", email = "user@example.com", name = "User With Dots",
        roles = ["standard"], disabled = false, send_user_invitation = true },
      { username = "user_with_underscores", email = "user2@example.com", name = "User With Underscores",
        roles = ["admin"], disabled = false, send_user_invitation = true }
    ]
  }

  # Resource count
  assert {
    condition = length(keys(datadog_user.users)) == 4
    error_message = "Should create exactly four datadog_user resources"
  }

  # Key generation tests
  assert {
    condition = contains(keys(datadog_user.users), "alice.admin")
    error_message = "Should create resource with key 'alice.admin'"
  }

  assert {
    condition = contains(keys(datadog_user.users), "bob.readonly")
    error_message = "Should create resource with key 'bob.readonly'"
  }

  assert {
    condition = contains(keys(datadog_user.users), "user.with.dots")
    error_message = "Should handle usernames with dots correctly"
  }

  assert {
    condition = contains(keys(datadog_user.users), "user_with_underscores")
    error_message = "Should handle usernames with underscores correctly"
  }

  # Disabled state tests
  assert {
    condition = datadog_user.users["alice.admin"].disabled == false
    error_message = "Alice should be enabled"
  }

  assert {
    condition = datadog_user.users["bob.readonly"].disabled == true
    error_message = "Bob should be disabled"
  }

  # Invitation state tests
  assert {
    condition = datadog_user.users["alice.admin"].send_user_invitation == true
    error_message = "Alice should send invitation"
  }

  assert {
    condition = datadog_user.users["bob.readonly"].send_user_invitation == false
    error_message = "Bob should not send invitation"
  }

  # Role count tests (accounting for set deduplication with mock)
  assert {
    condition = length(datadog_user.users["alice.admin"].roles) >= 1
    error_message = "Alice should have at least one role assigned"
  }

  assert {
    condition = length(datadog_user.users["bob.readonly"].roles) == 1
    error_message = "Bob should have exactly one role assigned"
  }

  assert {
    condition = length(datadog_user.users["user.with.dots"].roles) == 1
    error_message = "User with dots should have exactly one role assigned"
  }

  assert {
    condition = length(datadog_user.users["user_with_underscores"].roles) == 1
    error_message = "User with underscores should have exactly one role assigned"
  }

  # Role mapping tests
  assert {
    condition = alltrue([
      for role in datadog_user.users["alice.admin"].roles : role == "mock-role-id"
    ])
    error_message = "All of Alice's roles should be mapped to mock role IDs"
  }

  assert {
    condition = alltrue([
      for role in datadog_user.users["bob.readonly"].roles : role == "mock-role-id"
    ])
    error_message = "All of Bob's roles should be mapped to mock role IDs"
  }

  # Email and name preservation tests
  assert {
    condition = datadog_user.users["bob.readonly"].name == "Bob ReadOnly"
    error_message = "Bob should have correct name assigned"
  }

  assert {
    condition = datadog_user.users["user.with.dots"].email == "user@example.com"
    error_message = "User with dots should have correct email assigned"
  }

  assert {
    condition = datadog_user.users["user_with_underscores"].email == "user2@example.com"
    error_message = "User with underscores should have correct email assigned"
  }
}
