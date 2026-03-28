require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    post = Post.new(title: "Hello World", content: "Some content")
    assert post.valid?
  end

  test "invalid without title" do
    post = Post.new(content: "Some content")
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "invalid with title over 255 characters" do
    post = Post.new(title: "a" * 256, content: "Some content")
    assert_not post.valid?
    assert post.errors[:title].any?
  end

  test "invalid without content" do
    post = Post.new(title: "Hello World")
    assert_not post.valid?
    assert_includes post.errors[:content], "can't be blank"
  end

  test "invalid with excerpt over 500 characters" do
    post = Post.new(title: "Hello", content: "Content", excerpt: "a" * 501)
    assert_not post.valid?
    assert post.errors[:excerpt].any?
  end

  test "nil excerpt is valid" do
    post = Post.new(title: "Hello", content: "Content", excerpt: nil)
    assert post.valid?
  end

  test "invalid with duplicate slug" do
    Post.create!(title: "First", content: "Content", slug: "same-slug")
    post = Post.new(title: "Second", content: "Content", slug: "same-slug")
    assert_not post.valid?
    assert_includes post.errors[:slug], "has already been taken"
  end

  test "generates slug from title on create" do
    post = Post.create!(title: "Hello World Post", content: "Content")
    assert_equal "hello-world-post", post.slug
  end

  test "strips special characters from slug" do
    post = Post.create!(title: "Hello, World! #1", content: "Content")
    assert_equal "hello-world-1", post.slug
  end

  test "generates unique slug when collision exists" do
    Post.create!(title: "My Post", content: "Content")
    post = Post.create!(title: "My Post", content: "Other content")
    assert_equal "my-post-1", post.slug
  end

  test "does not overwrite explicit slug on create" do
    post = Post.create!(title: "My Post", content: "Content", slug: "custom-slug")
    assert_equal "custom-slug", post.slug
  end

  # published scope
  test "published scope returns published posts with past published_at" do
    assert_includes Post.published, posts(:published)
  end

  test "published scope excludes drafts" do
    assert_not_includes Post.published, posts(:draft)
  end

  test "published scope excludes future scheduled posts" do
    assert_not_includes Post.published, posts(:future)
  end

  test "published scope excludes published post with nil published_at" do
    post = Post.create!(title: "No Date", content: "Content", is_published: true, published_at: nil)
    assert_not_includes Post.published, post
  end
end
