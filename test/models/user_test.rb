require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid with email and password" do
    user = User.new(email: "test@example.com", password: "secret123", password_confirmation: "secret123")
    assert user.valid?
  end

  test "invalid without email" do
    user = User.new(password: "secret123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "invalid with duplicate email" do
    User.create!(email: "dup@example.com", password: "secret123")
    user = User.new(email: "dup@example.com", password: "secret123")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "invalid with malformed email" do
    user = User.new(email: "not-an-email", password: "secret123")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "authenticates with correct password" do
    user = users(:admin)
    assert user.authenticate("password")
  end

  test "rejects wrong password" do
    user = users(:admin)
    assert_not user.authenticate("wrong")
  end
end
