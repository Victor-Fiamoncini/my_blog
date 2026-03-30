email    = ENV.fetch("ADMIN_EMAIL", "admin@blog.com")
password = ENV.fetch("ADMIN_PASSWORD", "password")

User.find_or_create_by!(email: email) do |u|
  u.password = password
end

puts "Admin user: #{email}"

unless Rails.env.development? || Rails.env.test?
  puts "Skipping post seeds (non-dev/test environment)"
  return
end

[
  {
    title: "Getting Started with Ruby on Rails",
    excerpt: "A beginner-friendly introduction to building web applications with Ruby on Rails.",
    content: "Ruby on Rails is a web application framework written in Ruby. It follows the MVC pattern and emphasizes convention over configuration, making it easy to get started quickly.",
    is_published: true,
    published_at: 2.days.ago
  },
  {
    title: "Understanding ActiveRecord Associations",
    excerpt: "Deep dive into belongs_to, has_many, and has_many :through associations in Rails.",
    content: "ActiveRecord associations allow you to define relationships between models. The most common associations are belongs_to, has_many, has_one, and has_many :through for join tables.",
    is_published: true,
    published_at: 1.day.ago
  },
  {
    title: "Rails Testing with Minitest",
    excerpt: "How to write effective unit and integration tests using Rails' built-in Minitest framework.",
    content: "Rails ships with Minitest out of the box. You can write model tests, controller tests, and system tests to ensure your application behaves correctly as it grows.",
    is_published: false,
    published_at: nil
  }
].each do |attrs|
  Post.find_or_create_by!(title: attrs[:title]) do |post|
    post.assign_attributes(attrs)
  end
end

puts "3 posts seeded"
