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

# Test: Multiple users with comprehensive configuration testing
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

  # Validate resource creation and key generation
  assert {
    condition     = length(keys(datadog_user.users)) == 4
    error_message = "Should create exactly four datadog_user resources"
  }

  assert {
    condition = alltrue([
      for username in ["alice.admin", "bob.readonly", "user.with.dots", "user_with_underscores"] :
      contains(keys(datadog_user.users), username)
    ])
    error_message = "Should handle all username formats (dots, underscores) as resource keys"
  }

  # Validate attribute preservation for specific test cases
  assert {
    condition = (
      datadog_user.users["alice.admin"].disabled == false &&
      datadog_user.users["bob.readonly"].disabled == true &&
      datadog_user.users["alice.admin"].send_user_invitation == true &&
      datadog_user.users["bob.readonly"].send_user_invitation == false
    )
    error_message = "User attributes (disabled, send_user_invitation) should be preserved correctly"
  }

  # Validate role mapping and mock behavior
  assert {
    condition = alltrue([
      for user_key, user in datadog_user.users :
      alltrue([for role in user.roles : role == "mock-role-id"])
    ])
    error_message = "All user roles should be mapped to mock role IDs"
  }

  # Validate email and name preservation for edge cases
  assert {
    condition = (
      datadog_user.users["user.with.dots"].email == "user@example.com" &&
      datadog_user.users["user_with_underscores"].email == "user2@example.com" &&
      datadog_user.users["bob.readonly"].name == "Bob ReadOnly"
    )
    error_message = "Email and name attributes should be preserved for all username formats"
  }
}
