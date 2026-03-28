require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  test "homepage shows published posts" do
    visit root_url
    assert_text(/my published post/i)
  end

  test "homepage does not show draft posts" do
    visit root_url
    assert_no_text(/my draft post/i)
  end

  test "homepage does not show future scheduled posts" do
    visit root_url
    assert_no_text(/my future post/i)
  end

  test "can navigate to a published post" do
    visit root_url
    find("a", text: /my published post/i).click
    assert_current_path post_path(posts(:published).slug)
  end

  test "post page shows title and content" do
    visit post_url(posts(:published).slug)
    assert_text(/my published post/i)
    assert_text "This is the full content of the published post."
  end

  test "post page shows excerpt when present" do
    visit post_url(posts(:published).slug)
    assert_text "A short excerpt for the published post."
  end
end
