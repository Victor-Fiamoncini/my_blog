# Stress-test seeder — safe to run in any environment.
# Creates 1 admin user + 30 published posts with varied content.
# Existing records are left untouched (find_or_create_by!).

# ── Admin user ────────────────────────────────────────────────────────────────
email    = ENV.fetch("ADMIN_EMAIL", "admin@blog.com")
password = ENV.fetch("ADMIN_PASSWORD", "password1234")

User.find_or_create_by!(email: email) do |u|
  u.password = password
end

puts "Admin: #{email}"

# ── Posts ─────────────────────────────────────────────────────────────────────
POSTS = [
  {
    title:   "Getting Started with Ruby on Rails",
    excerpt: "A beginner-friendly introduction to building web applications with Ruby on Rails.",
    content: <<~'MD'
      # Getting Started with Ruby on Rails

      Ruby on Rails is a full-stack web framework written in Ruby. It follows the **MVC pattern**
      and emphasizes _convention over configuration_, letting you get productive quickly.

      ## Installation

      ```bash
      gem install rails
      rails new my_app
      cd my_app
      bin/rails server
      ```

      Visit `http://localhost:3000` and you're up and running.

      ## The MVC Pattern

      | Layer | Responsibility |
      |-------|---------------|
      | Model | Business logic and database access |
      | View  | HTML templates rendered to the browser |
      | Controller | Handles requests and coordinates M + V |

      Rails generates all three layers with a single scaffold command.
    MD
  },
  {
    title:   "Understanding ActiveRecord Associations",
    excerpt: "Deep dive into belongs_to, has_many, and has_many :through in Rails.",
    content: <<~'MD'
      # ActiveRecord Associations

      Associations let you declare relationships between models concisely.

      ## belongs_to / has_many

      ```ruby
      class Post < ApplicationRecord
        belongs_to :user
        has_many :comments, dependent: :destroy
      end
      ```

      ## has_many :through

      Use a join model when the relationship carries extra data:

      ```ruby
      class Post < ApplicationRecord
        has_many :taggings
        has_many :tags, through: :taggings
      end
      ```

      ## Eager Loading

      Avoid N+1 queries with `includes`:

      ```ruby
      Post.includes(:comments, :tags).published
      ```
    MD
  },
  {
    title:   "Tailwind CSS Tips for Rails Developers",
    excerpt: "Practical Tailwind patterns that work well with Rails view conventions.",
    content: <<~'MD'
      # Tailwind CSS in Rails

      Rails 8 ships with Tailwind CSS support out of the box via `tailwindcss-rails`.

      ## Utility-First Approach

      Instead of writing custom CSS, compose utilities directly in your templates:

      ```erb
      <div class="max-w-prose mx-auto px-4 py-8">
        <h1 class="text-3xl font-bold text-gray-900"><%= @post.title %></h1>
      </div>
      ```

      ## Responsive Design

      Tailwind's responsive prefixes make breakpoints explicit:

      ```html
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      ```

      ## Dark Mode

      Enable `darkMode: 'class'` in `tailwind.config.js` and toggle a class on `<html>`.
    MD
  },
  {
    title:   "Hotwire and Turbo: Real-Time Rails Without Writing JavaScript",
    excerpt: "How Hotwire's Turbo Drive, Frames, and Streams work together for SPA-like UX.",
    content: <<~'MD'
      # Hotwire in Rails 8

      Hotwire is the default front-end stack in Rails 8. It ships with:

      - **Turbo Drive** — intercepts link clicks and form submissions, swaps `<body>` via fetch
      - **Turbo Frames** — decompose pages into independent, lazily-loaded sections
      - **Turbo Streams** — push partial DOM updates over WebSockets or SSE

      ## Turbo Frames Example

      ```erb
      <%# app/views/posts/_post.html.erb %>
      <%= turbo_frame_tag dom_id(post) do %>
        <h2><%= post.title %></h2>
        <%= link_to "Edit", edit_post_path(post) %>
      <% end %>
      ```

      Clicking "Edit" replaces only that frame — no full page reload.
    MD
  },
  {
    title:   "SQLite in Production: When It's the Right Choice",
    excerpt: "A practical look at SQLite's strengths and limits for small-to-medium Rails apps.",
    content: <<~'MD'
      # SQLite in Production

      Rails 8 embraces SQLite for production workloads that fit its model:
      single-server deployments with read-heavy traffic.

      ## Why It Works

      - No separate database server process
      - WAL mode enables concurrent reads with a single writer
      - Filesystem-level backups with `sqlite3 .backup`
      - Sub-millisecond local I/O

      ## Enabling WAL Mode

      Rails 8 sets this automatically, but you can verify:

      ```ruby
      ActiveRecord::Base.connection.execute("PRAGMA journal_mode=WAL")
      ```

      ## When to Move On

      Consider PostgreSQL when you need multiple write-heavy workers,
      full-text search at scale, or cross-server replication.
    MD
  },
  {
    title:   "Deploying Rails with Kamal",
    excerpt: "Zero-downtime deploys to a bare VPS using Kamal and Docker.",
    content: <<~'MD'
      # Deploying with Kamal

      Kamal is Rails' official deploy tool. It uses Docker to ship your app
      to any VPS without a platform fee.

      ## Minimal config

      ```yaml
      # config/deploy.yml
      service: my_blog
      image: user/my_blog
      servers:
        - 203.0.113.1
      registry:
        server: ghcr.io
        username: <%= ENV["GITHUB_USER"] %>
        password: <%= ENV["GITHUB_TOKEN"] %>
      ```

      ## First deploy

      ```bash
      kamal setup   # provisions server, installs Docker
      kamal deploy  # builds image, pushes, swaps container
      ```

      Kamal uses Traefik as a reverse proxy and handles zero-downtime swaps
      with health-check polling.
    MD
  },
  {
    title:   "Writing Fast Rails Tests with Minitest",
    excerpt: "Strategies for keeping your Minitest suite fast as the codebase grows.",
    content: <<~'MD'
      # Fast Minitest in Rails

      Slow tests kill productivity. Here's how to keep the suite snappy.

      ## Parallelize

      Rails parallelizes tests by default with forked processes:

      ```ruby
      # test/test_helper.rb
      parallelize(workers: :number_of_processors)
      ```

      ## Avoid Fixtures for Complex State

      Use **factory methods** in your test class instead of large fixture files:

      ```ruby
      def create_published_post(title: "Sample")
        Post.create!(title: title, content: "x", is_published: true, published_at: 1.day.ago)
      end
      ```

      ## Focus on Integration Boundaries

      Don't test every private method. Test at the controller or model boundary
      and trust Ruby's object model for the rest.
    MD
  },
  {
    title:   "Kaminari Pagination Patterns",
    excerpt: "Tips for paginating large datasets elegantly in Rails views.",
    content: <<~'MD'
      # Kaminari in Rails

      Kaminari is the most popular pagination gem for Rails. Add it to your Gemfile
      and call `.page` on any ActiveRecord relation.

      ## Basic Usage

      ```ruby
      # controller
      @posts = Post.published.page(params[:page]).per(9)

      # view
      <%= paginate @posts %>
      ```

      ## Custom Page Sizes

      Override per-page globally or per-query:

      ```ruby
      Kaminari.configure { |c| c.default_per_page = 12 }

      # or per query:
      Post.page(1).per(24)
      ```

      ## Turbo-Compatible Navigation

      Wrap the paginator in a `turbo_frame_tag` so navigation only replaces
      the post grid, not the whole page.
    MD
  },
  {
    title:   "Markdown Rendering with Redcarpet",
    excerpt: "Setting up Redcarpet in Rails and customizing the renderer for your blog.",
    content: <<~'MD'
      # Redcarpet in Rails

      Redcarpet is a fast, C-backed Markdown renderer. Rails blogs commonly use it
      with a custom renderer for syntax highlighting.

      ## Setup

      ```ruby
      # Gemfile
      gem "redcarpet"
      gem "rouge"  # or highlight.js on the client side
      ```

      ## Custom Renderer

      ```ruby
      class HighlightRenderer < Redcarpet::Render::HTML
        def block_code(code, language)
          "<pre><code class=\"language-#{language}\">#{CGI.escapeHTML(code)}</code></pre>"
        end
      end

      def markdown(text)
        options  = { fenced_code_blocks: true, autolink: true, tables: true }
        renderer = HighlightRenderer.new(link_attributes: { target: "_blank" })
        Redcarpet::Markdown.new(renderer, options).render(text)
      end
      ```
    MD
  },
  {
    title:   "Stimulus.js Controllers for Rails Developers",
    excerpt: "How to write lightweight Stimulus controllers that complement Turbo.",
    content: <<~'MD'
      # Stimulus.js

      Stimulus is a modest JavaScript framework that enhances server-rendered HTML.
      Each controller is a small class bound to a DOM element via `data-controller`.

      ## Hello World

      ```javascript
      // app/javascript/controllers/toggle_controller.js
      import { Controller } from "@hotwired/stimulus"

      export default class extends Controller {
        static targets = ["menu"]

        toggle() {
          this.menuTarget.classList.toggle("hidden")
        }
      }
      ```

      ```html
      <div data-controller="toggle">
        <button data-action="click->toggle#toggle">Menu</button>
        <nav data-toggle-target="menu" class="hidden">...</nav>
      </div>
      ```

      ## Values API

      Pass server-side data to JS without inline scripts:

      ```html
      <div data-controller="chart" data-chart-url-value="/stats.json">
      ```
    MD
  },
  {
    title:   "Rails Security Checklist",
    excerpt: "The most important security measures for a production Rails application.",
    content: <<~'MD'
      # Rails Security Checklist

      ## Authentication

      - Use `has_secure_password` — it handles bcrypt hashing automatically
      - Enforce strong passwords with `validates :password, length: { minimum: 12 }`
      - Rotate `secret_key_base` if it's ever exposed

      ## Authorization

      - Use `before_action :require_login` on every admin controller
      - Never trust `params[:user_id]` to determine access

      ## Input Sanitization

      - Strong parameters (`permit`) block mass-assignment by default in Rails
      - Always use parameterized queries — ActiveRecord does this automatically
      - Sanitize HTML if you accept user-generated markup

      ## Headers

      Rails sets secure headers by default. Verify with Brakeman:

      ```bash
      bin/brakeman --no-pager
      ```
    MD
  },
  {
    title:   "Import Maps in Rails 8",
    excerpt: "How import maps replace webpack/esbuild for most Rails applications.",
    content: <<~'MD'
      # Import Maps in Rails 8

      Import maps let browsers resolve bare module specifiers without a bundler.
      Rails ships `importmap-rails` as the default JS setup.

      ## Pinning a Package

      ```bash
      bin/importmap pin @hotwired/stimulus
      ```

      This appends to `config/importmap.rb`:

      ```ruby
      pin "@hotwired/stimulus", to: "https://cdn.skypack.dev/@hotwired/stimulus"
      ```

      ## When to Use a Bundler Instead

      Reach for esbuild or Vite when you need:
      - TypeScript with type checking
      - JSX / React / Vue components
      - Complex tree-shaking for large dependency graphs

      For most content sites and admin dashboards, import maps are sufficient.
    MD
  },
  {
    title:   "Propshaft: Rails' New Asset Pipeline",
    excerpt: "What changed from Sprockets to Propshaft and how to adapt your workflow.",
    content: <<~'MD'
      # Propshaft Asset Pipeline

      Propshaft replaces Sprockets as the recommended asset pipeline in Rails 8.
      Its design is intentionally simpler: **copy, digest, serve**.

      ## What It Does

      1. Collects assets from `app/assets/**`
      2. Appends a content-based digest to each filename (`app-a1b2c3.css`)
      3. Serves them from `public/assets` in production

      ## What It Doesn't Do

      - No transpilation (JS bundling is handled by import maps or a separate bundler)
      - No Sass compilation (use `dartsass-rails` separately)
      - No concatenation

      ## Referencing Assets in Views

      ```erb
      <%= image_tag "logo.svg" %>          <%# resolves to /assets/logo-abc123.svg %>
      <%= stylesheet_link_tag "application" %>
      ```
    MD
  },
  {
    title:   "Background Jobs with Solid Queue",
    excerpt: "Rails 8's built-in job backend that runs on SQLite — no Redis needed.",
    content: <<~'MD'
      # Solid Queue

      Solid Queue is the default Active Job backend in Rails 8. It stores jobs
      in the database, so there's no need for Redis on small deployments.

      ## Setup

      Rails 8 generates a `queue.sqlite3` database automatically.
      The queue worker starts alongside your app via `bin/dev`.

      ## Enqueueing a Job

      ```ruby
      class WelcomeEmailJob < ApplicationJob
        queue_as :default

        def perform(user_id)
          user = User.find(user_id)
          UserMailer.welcome(user).deliver_now
        end
      end

      WelcomeEmailJob.perform_later(user.id)
      ```

      ## Concurrency & Priorities

      Configure workers in `config/queue.yml`:

      ```yaml
      default:
        queues: [default, mailers]
        threads: 3
      ```
    MD
  },
  {
    title:   "Caching Strategies in Rails",
    excerpt: "Fragment caching, Russian doll caching, and HTTP caching with Rails.",
    content: <<~'MD'
      # Caching in Rails

      ## Fragment Caching

      Cache expensive view partials:

      ```erb
      <% cache post do %>
        <%= render post %>
      <% end %>
      ```

      The cache key is derived from `post.cache_key_with_version`, which changes
      when the record is updated — so stale content is never served.

      ## Russian Doll Caching

      Nest caches so parent expiry cascades from children:

      ```erb
      <% cache [@posts, "v1"] do %>
        <% @posts.each do |post| %>
          <% cache post do %>
            <%= render post %>
          <% end %>
        <% end %>
      <% end %>
      ```

      ## HTTP Caching

      Use `stale?` in controllers to return 304 Not Modified:

      ```ruby
      def show
        @post = Post.find_by!(slug: params[:slug])
        return unless stale?(@post)
        render :show
      end
      ```
    MD
  },
  {
    title:   "Building a JSON API with Rails",
    excerpt: "Practical patterns for building versioned, authenticated JSON APIs in Rails.",
    content: <<~'MD'
      # JSON API in Rails

      Rails is a great fit for JSON APIs. Skip the view layer with `--api` mode.

      ## Rendering JSON

      ```ruby
      def index
        @posts = Post.published.page(params[:page])
        render json: {
          posts: @posts.as_json(only: [:id, :title, :slug, :published_at]),
          meta: { total_pages: @posts.total_pages }
        }
      end
      ```

      ## Versioning

      Namespace controllers by version:

      ```
      app/controllers/api/v1/posts_controller.rb
      ```

      ```ruby
      namespace :api do
        namespace :v1 do
          resources :posts, only: [:index, :show]
        end
      end
      ```

      ## Authentication

      Use `has_secure_token` for API keys or JWT for stateless auth.
    MD
  },
  {
    title:   "ActiveStorage for File Uploads",
    excerpt: "Attaching images and files to Rails models with ActiveStorage and cloud storage.",
    content: <<~'MD'
      # ActiveStorage

      ActiveStorage provides file attachment for Rails models with pluggable
      cloud backends (S3, GCS, Azure).

      ## Attaching a File

      ```ruby
      class Post < ApplicationRecord
        has_one_attached :cover_image
      end
      ```

      ```erb
      <%= form.file_field :cover_image, accept: "image/*" %>
      <%= image_tag @post.cover_image if @post.cover_image.attached? %>
      ```

      ## Image Variants

      Resize on-the-fly with the variants API:

      ```ruby
      @post.cover_image.variant(resize_to_limit: [800, 400]).processed.url
      ```

      Requires `libvips` or `ImageMagick` on the server.

      ## Direct Uploads

      Skip your server entirely — upload directly to cloud storage from the browser
      with `activestorage.js` and `direct_upload: true`.
    MD
  },
  {
    title:   "Action Mailer in Production",
    excerpt: "Configuring SMTP, previewing emails, and testing mailers in Rails.",
    content: <<~'MD'
      # Action Mailer

      ## Configuration

      ```ruby
      # config/environments/production.rb
      config.action_mailer.smtp_settings = {
        address:              "smtp.postmarkapp.com",
        port:                 587,
        user_name:            Rails.application.credentials.smtp_user,
        password:             Rails.application.credentials.smtp_password,
        authentication:       :plain,
        enable_starttls_auto: true
      }
      ```

      ## Email Previews

      Preview emails in development without sending them:

      ```ruby
      # test/mailers/previews/user_mailer_preview.rb
      class UserMailerPreview < ActionMailer::Preview
        def welcome
          UserMailer.welcome(User.first)
        end
      end
      ```

      Visit `/rails/mailers/user_mailer/welcome` to preview.
    MD
  },
  {
    title:   "Debugging Rails Apps with Pry and Debug",
    excerpt: "Using Ruby's built-in debugger and pry-rails to inspect running Rails processes.",
    content: <<~'MD'
      # Debugging Rails

      ## Built-in Debugger (Ruby 3.1+)

      Drop a breakpoint anywhere:

      ```ruby
      def show
        @post = Post.find_by!(slug: params[:slug])
        debugger  # execution halts here in dev
      end
      ```

      Attach with `bin/rails server` and the debugger REPL opens in the terminal.

      ## Useful Commands

      | Command | Effect |
      |---------|--------|
      | `next`  | Step over |
      | `step`  | Step into |
      | `finish`| Run until method returns |
      | `p expr`| Print expression |
      | `ls`    | List available methods |

      ## Logging

      Increase log verbosity for a specific request:

      ```ruby
      Rails.logger.debug { "params: #{params.inspect}" }
      ```
    MD
  },
  {
    title:   "Performance Profiling with rack-mini-profiler",
    excerpt: "Identifying slow queries and view rendering bottlenecks in Rails.",
    content: <<~'MD'
      # rack-mini-profiler

      Add to your Gemfile (development group):

      ```ruby
      gem "rack-mini-profiler"
      gem "memory_profiler"
      gem "stackprof"
      ```

      A speed badge appears in the top-left corner showing:

      - Total request time
      - SQL query count and duration
      - View render time per partial

      ## Flamegraphs

      Append `?pp=flamegraph` to any URL to generate a CPU flamegraph — excellent
      for finding hot code paths.

      ## N+1 Detection

      Combine with `bullet` gem to get alerts when eager loading would help:

      ```ruby
      Bullet.enable = true
      Bullet.alert  = true
      ```
    MD
  },
  {
    title:   "Structuring Large Rails Applications",
    excerpt: "Patterns for organizing business logic as your Rails app scales.",
    content: <<~'MD'
      # Structuring Large Rails Apps

      Rails doesn't prescribe where business logic lives beyond models and controllers.
      These patterns help as the app grows.

      ## Service Objects

      Extract multi-step operations into plain Ruby classes:

      ```ruby
      # app/services/publish_post.rb
      class PublishPost
        def initialize(post)
          @post = post
        end

        def call
          @post.update!(is_published: true, published_at: Time.current)
        end
      end

      PublishPost.new(@post).call
      ```

      ## Query Objects

      Encapsulate complex scopes:

      ```ruby
      class PublishedPostsQuery
        def initialize(relation = Post.all)
          @relation = relation
        end

        def call
          @relation.where(is_published: true).where("published_at <= ?", Time.current)
        end
      end
      ```

      ## Avoid Callbacks for Side Effects

      Prefer explicit service calls over `after_save` for sending emails,
      invalidating caches, or triggering jobs.
    MD
  }
].freeze

created = 0

POSTS.each_with_index do |attrs, i|
  Post.find_or_create_by!(title: attrs[:title]) do |post|
    post.content      = attrs[:content]
    post.excerpt      = attrs[:excerpt]
    post.is_published = true
    post.published_at = (POSTS.size - i).days.ago
  end

  created += 1
end

puts "#{created} posts seeded"
puts "Slugs:"
Post.published.order(:published_at).pluck(:slug).each { |s| puts "  - #{s}" }
