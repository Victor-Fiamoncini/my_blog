require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "GET login returns 200" do
    get login_url
    assert_response :success
  end

  test "GET login redirects to dashboard when already logged in" do
    post login_url, params: { email: users(:admin).email, password: "password" }
    get login_url
    assert_redirected_to dashboard_root_url
  end

  test "POST login with valid credentials redirects to dashboard" do
    post login_url, params: { email: users(:admin).email, password: "password" }
    assert_redirected_to dashboard_root_url
  end

  test "POST login with valid credentials sets session" do
    post login_url, params: { email: users(:admin).email, password: "password" }
    assert_equal users(:admin).id, session[:user_id]
  end

  test "POST login with wrong password renders new with 422" do
    post login_url, params: { email: users(:admin).email, password: "wrong" }
    assert_response :unprocessable_entity
    assert_select "p", text: /do not match/
  end

  test "POST login with unknown email renders new with 422" do
    post login_url, params: { email: "nobody@example.com", password: "password" }
    assert_response :unprocessable_entity
  end

  test "DELETE logout clears session and redirects to root" do
    post login_url, params: { email: users(:admin).email, password: "password" }
    delete logout_url
    assert_nil session[:user_id]
    assert_redirected_to root_url
  end
end
