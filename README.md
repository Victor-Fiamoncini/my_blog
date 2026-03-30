# My Blog 💎

A personal blog built with Ruby on Rails, featuring a public-facing reading experience and a private admin dashboard for writing and managing posts.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Ruby on Rails 8.1 |
| Language | Ruby 4.0.2 |
| Database | PostgreSQL 17 |
| CSS | Tailwind CSS |
| Frontend | Hotwire (Turbo + Stimulus) |
| Asset pipeline | Propshaft |
| JS loading | Import maps |
| Markdown | Redcarpet |
| Pagination | Kaminari |
| Auth | `has_secure_password` (bcrypt) |
| Web server | Puma |

## Getting Started

### Prerequisites

- Ruby 4.0.2 (use `rbenv` or `asdf` to manage versions)
- Bundler
- Docker (for the PostgreSQL container)

### Setup

```bash
docker compose up -d   # Start PostgreSQL
bin/setup              # Install gems, prepare database, clear logs
bin/dev                # Start the development server (Rails + Tailwind watcher)
```

Visit `http://localhost:3000` for the public blog, or `http://localhost:3000/dashboard` to log in to the admin area.

To reset the database from scratch:

```bash
bin/setup --reset
```

## Architecture

### Public vs. Admin separation

Two distinct areas with separate layouts:

- **Public** (`PostsController` → `application.html.erb`): read-only, shows only published posts
- **Admin** (`Dashboard::PostsController` → `dashboard.html.erb`): full CRUD, gated by `before_action :require_login`
- **Auth** (`SessionsController`): session-based login — any authenticated user is an admin (no roles system)

### Post publishing model

Posts have two visibility fields: `is_published` (boolean) and `published_at` (datetime). A post appears publicly only when **both** conditions are true: `is_published = true` AND `published_at` is in the past. This allows scheduling posts for future publication.

The dashboard controller manages `published_at` automatically:
- First publish → sets `published_at = Time.current`
- Edit while published → preserves original `published_at`
- Unpublish → clears `published_at`

### Slug generation

`Post` auto-generates a URL slug from the title on creation (via `before_validation`). Special characters are stripped and spaces become hyphens. Collisions are resolved by appending `-1`, `-2`, etc. Setting a slug manually before save skips auto-generation.

### Pagination

Kaminari paginates index actions. Public posts: 9 per page. Dashboard posts: 15 per page.

### JavaScript

Import maps pin Turbo, Stimulus, and Highlight.js. Local JS lives in `app/javascript/`. Syntax highlighting assets are in `app/assets/highlight.min.js` and `app/assets/stylesheets/highlight/`.

## Development Commands

```bash
bin/rails test                      # Run all tests
bin/rails test:system               # Run system tests
bin/rails test path/to/test.rb:42   # Run a single test at a line

bin/rubocop                         # Lint Ruby (rubocop-rails-omakase)
bin/brakeman --no-pager             # Security scan
bin/ci                              # Full CI: setup + lint + security + tests
```
