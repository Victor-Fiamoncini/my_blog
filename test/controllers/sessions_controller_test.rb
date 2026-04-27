require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { Rails.cache.clear }

  test "GET login returns 200" do
    get login_url
    assert_response :success
  end

  test "GET login redirects to dashboard when already logged in" do
    post login_url, params: { email: users(:admin).email, password: "password1234" }
    get login_url
    assert_redirected_to dashboard_root_url
  end

  test "POST login with valid credentials redirects to dashboard" do
    post login_url, params: { email: users(:admin).email, password: "password1234" }
    assert_redirected_to dashboard_root_url
  end

  test "POST login with valid credentials sets session" do
    post login_url, params: { email: users(:admin).email, password: "password1234" }
    assert_equal users(:admin).id, session[:user_id]
  end

  test "POST login with wrong password renders new with 422" do
    post login_url, params: { email: users(:admin).email, password: "wrong" }
    assert_response :unprocessable_entity
    assert_select "p", text: /do not match/
  end

  test "POST login with unknown email renders new with 422" do
    post login_url, params: { email: "nobody@example.com", password: "password1234" }
    assert_response :unprocessable_entity
  end

  test "DELETE logout clears session and redirects to root" do
    post login_url, params: { email: users(:admin).email, password: "password1234" }
    delete logout_url
    assert_nil session[:user_id]
    assert_redirected_to root_url
  end

  # rate limiting
  test "POST login returns 429 after exceeding 5 attempts per minute" do
    6.times { post login_url, params: { email: "x@x.com", password: "wrong" } }
    assert_response :too_many_requests
  end
end
