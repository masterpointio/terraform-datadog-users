mock_provider "datadog" {
  mock_data "datadog_role" {
    defaults = {
      id = "mock-role-id"
    }
  }
}

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
