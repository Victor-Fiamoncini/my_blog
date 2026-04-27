require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup { Rails.cache.clear }

  # index
  test "GET index returns 200" do
    get root_url
    assert_response :success
  end

  test "GET index shows published posts" do
    get root_url
    assert_select "a", text: /My Published Post/
  end

  test "GET index does not show draft posts" do
    get root_url
    assert_select "a", text: /My Draft Post/, count: 0
  end

  test "GET index does not show future scheduled posts" do
    get root_url
    assert_select "a", text: /My Future Post/, count: 0
  end

  # show
  test "GET show returns 200 for a published post" do
    get post_url(posts(:published).slug)
    assert_response :success
  end

  test "GET show displays post title and content" do
    get post_url(posts(:published).slug)
    assert_select "h1", text: /My Published Post/
  end

  test "GET show returns 404 for a draft post" do
    get post_url(posts(:draft).slug)
    assert_response :not_found
  end

  test "GET show returns 404 for a future post" do
    get post_url(posts(:future).slug)
    assert_response :not_found
  end

  test "GET show returns 404 for unknown slug" do
    get post_url("does-not-exist")
    assert_response :not_found
  end

  test "GET show renders custom 404 page for unknown slug" do
    get post_url("does-not-exist")
    assert_select "h1", text: /404/
    assert_select "a", text: /Back to Posts/
  end

  test "GET show renders custom 404 page for draft post" do
    get post_url(posts(:draft).slug)
    assert_select "h1", text: /404/
    assert_select "a", text: /Back to Posts/
  end

  # rate limiting
  test "GET index returns 429 after exceeding 30 requests per minute" do
    31.times { get root_url }
    assert_response :too_many_requests
  end

  test "GET show returns 429 after exceeding 30 requests per minute" do
    31.times { get post_url(posts(:published).slug) }
    assert_response :too_many_requests
  end
end
