require "test_helper"

module Dashboard
  class PostsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @post = posts(:published)
    end

    # Authentication guard
    test "GET index redirects to login when not authenticated" do
      get dashboard_root_url
      assert_redirected_to login_url
    end

    test "GET new redirects to login when not authenticated" do
      get new_dashboard_post_url
      assert_redirected_to login_url
    end

    test "GET edit redirects to login when not authenticated" do
      get edit_dashboard_post_url(@post)
      assert_redirected_to login_url
    end

    # index
    test "GET index returns 200 when authenticated" do
      login
      get dashboard_root_url
      assert_response :success
    end

    test "GET index shows all posts" do
      login
      get dashboard_root_url
      assert_select "td", text: /My Published Post/
      assert_select "td", text: /My Draft Post/
    end

    # new
    test "GET new returns 200" do
      login
      get new_dashboard_post_url
      assert_response :success
    end

    # create
    test "POST create with valid params creates post and redirects to edit" do
      login
      assert_difference "Post.count", 1 do
        post dashboard_posts_url, params: { post: { title: "New Post", content: "Some content" } }
      end
      assert_redirected_to edit_dashboard_post_url(Post.last)
    end

    test "POST create sets published_at when is_published is checked" do
      login
      post dashboard_posts_url, params: {
        post: { title: "Pub Post", content: "Content", is_published: "1" }
      }
      created = Post.last
      assert created.is_published?
      assert_not_nil created.published_at
      assert created.published_at <= Time.current
    end

    test "POST create does not set published_at when draft" do
      login
      post dashboard_posts_url, params: {
        post: { title: "Draft Post", content: "Content", is_published: "0" }
      }
      assert_nil Post.last.published_at
    end

    test "POST create with invalid params renders new with 422" do
      login
      assert_no_difference "Post.count" do
        post dashboard_posts_url, params: { post: { title: "", content: "" } }
      end
      assert_response :unprocessable_entity
    end

    # edit
    test "GET edit returns 200" do
      login
      get edit_dashboard_post_url(@post)
      assert_response :success
    end

    # update
    test "PATCH update with valid params updates post and redirects to edit" do
      login
      patch dashboard_post_url(@post), params: { post: { title: "Updated Title", content: "Updated content" } }
      assert_redirected_to edit_dashboard_post_url(@post)
      assert_equal "Updated Title", @post.reload.title
    end

    test "PATCH update sets published_at when publishing for the first time" do
      login
      draft = posts(:draft)
      assert_nil draft.published_at
      patch dashboard_post_url(draft), params: {
        post: { title: draft.title, content: draft.content, is_published: "1" }
      }
      assert_not_nil draft.reload.published_at
    end

    test "PATCH update preserves published_at when post is already published" do
      login
      original_published_at = @post.published_at
      patch dashboard_post_url(@post), params: {
        post: { title: @post.title, content: @post.content, is_published: "1" }
      }
      assert_equal original_published_at.to_i, @post.reload.published_at.to_i
    end

    test "PATCH update clears published_at when unpublishing" do
      login
      patch dashboard_post_url(@post), params: {
        post: { title: @post.title, content: @post.content, is_published: "0" }
      }
      assert_nil @post.reload.published_at
      assert_not @post.reload.is_published?
    end

    test "PATCH update with invalid params renders edit with 422" do
      login
      patch dashboard_post_url(@post), params: { post: { title: "", content: "" } }
      assert_response :unprocessable_entity
    end

    # destroy
    test "DELETE destroy removes post and redirects to dashboard" do
      login
      assert_difference "Post.count", -1 do
        delete dashboard_post_url(@post)
      end
      assert_redirected_to dashboard_root_url
    end

    # toggle_published
    test "PATCH toggle_published publishes a draft post" do
      login
      draft = posts(:draft)
      patch toggle_published_dashboard_post_url(draft)
      assert draft.reload.is_published?
      assert_not_nil draft.reload.published_at
    end

    test "PATCH toggle_published unpublishes a published post" do
      login
      patch toggle_published_dashboard_post_url(@post)
      assert_not @post.reload.is_published?
      assert_nil @post.reload.published_at
    end

    private

    def login
      post login_url, params: { email: users(:admin).email, password: "password" }
    end
  end
end
