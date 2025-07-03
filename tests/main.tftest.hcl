# Test file for main.tf resource logic validation
# Focus: Testing datadog_user resource creation and basic attribute mapping

# Mock provider for Datadog resources and data sources
mock_provider "datadog" {
  mock_data "datadog_role" {
    defaults = {
      id = "mock-role-id"
    }
  }

  mock_resource "datadog_user" {
    defaults = {
      id = "mock-user-id"
    }
  }
}

# Test 1: Basic datadog_user resource creation
run "test_datadog_user_basic_creation" {
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
    condition = can(datadog_user.users["testuser"])
    error_message = "Should create datadog_user resource with key 'testuser'"
  }

  assert {
    condition = datadog_user.users["testuser"].email == "test@example.com"
    error_message = "User email should be correctly mapped to resource attribute"
  }
}

# Test 2: Complex multiple users and role mapping logic
run "test_multiple_users_and_role_mapping" {
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
        username             = "standard_user"
        email               = "standard@example.com"
        name                = "Standard User"
        roles               = ["standard"]
        disabled            = false
        send_user_invitation = true
      }
    ]
  }

  # Test that all three users are created
  assert {
    condition = length(keys(datadog_user.users)) == 3
    error_message = "Should create exactly 3 datadog_user resources"
  }

  # Test role mapping logic works (each user has roles populated)
  assert {
    condition = length(datadog_user.users["admin_user"].roles) == 1
    error_message = "Admin user should have 1 role mapped"
  }

  assert {
    condition = length(datadog_user.users["readonly_user"].roles) == 1
    error_message = "Read-only user should have 1 role mapped"
  }

  assert {
    condition = length(datadog_user.users["standard_user"].roles) == 1
    error_message = "Standard user should have 1 role mapped"
  }

  # Test that role mapping transformation works (roles are populated with mock IDs)
  assert {
    condition = alltrue([
      for role in datadog_user.users["admin_user"].roles :
      role == "mock-role-id"
    ])
    error_message = "Admin user roles should be mapped to mock data source ID"
  }

  # Test different attribute combinations
  assert {
    condition = datadog_user.users["readonly_user"].disabled == true
    error_message = "Read-only user should be disabled"
  }

  assert {
    condition = datadog_user.users["readonly_user"].send_user_invitation == false
    error_message = "Read-only user should not send invitation"
  }

  assert {
    condition = datadog_user.users["admin_user"].disabled == false
    error_message = "Admin user should be enabled"
  }

  # Test that resource keys match usernames (critical for for_each)
  assert {
    condition = alltrue([
      contains(keys(datadog_user.users), "admin_user"),
      contains(keys(datadog_user.users), "readonly_user"),
      contains(keys(datadog_user.users), "standard_user")
    ])
    error_message = "All expected user keys should be present in datadog_user resources"
  }

  # Test that names and emails are correctly mapped
  assert {
    condition = datadog_user.users["readonly_user"].name == "Read Only User"
    error_message = "Read-only user should have correct name"
  }

  assert {
    condition = datadog_user.users["standard_user"].email == "standard@example.com"
    error_message = "Standard user should have correct email"
  }
}
