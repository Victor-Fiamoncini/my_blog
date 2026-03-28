# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

Ruby on Rails 8.1, SQLite3, Tailwind CSS, Hotwire (Turbo + Stimulus), Propshaft, import maps.

## Commands

```bash
bin/dev          # Start dev server (Rails + Tailwind watcher via Foreman)
bin/setup        # Install gems, prepare DB, clear logs
bin/setup --reset  # Full DB reset

bin/rails test                # Run all tests
bin/rails test:system         # Run system tests
bin/rails test path/to/test.rb:42  # Run a single test at a line

bin/rubocop      # Lint Ruby (rubocop-rails-omakase style)
bin/brakeman --no-pager  # Security scan
bin/ci           # Full CI: setup + lint + security + tests
```

## Architecture

### Public vs. Admin separation

There are two distinct areas with separate layouts (`application.html.erb` vs `dashboard.html.erb`):

- **Public** (`PostsController`): read-only, shows only published posts
- **Admin** (`Dashboard::PostsController`): full CRUD, requires login via `before_action :require_login`
- **Auth** (`SessionsController`): session-based login with `has_secure_password`

Any authenticated user is an admin — there's no roles system.

### Post publishing model

Posts have two fields controlling visibility: `is_published` (boolean) and `published_at` (datetime). The public scope requires **both**: `is_published = true` AND `published_at` in the past. This enables scheduling future posts.

`Dashboard::PostsController` manages `published_at` automatically:
- First publish → sets `published_at = Time.current`
- Edit while published → preserves original `published_at`
- Unpublish → clears `published_at`

### Slug generation

`Post` auto-generates a slug from the title on creation (before_validation). Special characters are stripped, spaces become hyphens. Collisions are resolved by appending `-1`, `-2`, etc. Manually setting a slug before save skips auto-generation.

### Test helpers

A test-only route exists at `/test/login/:user_id` (conditionally defined in `config/routes.rb`) to bypass the password dance in tests.

### JavaScript

Import maps (`config/importmap.rb`) pin Turbo, Stimulus, and Highlight.js from CDN. Local JS lives in `app/javascript/`. Syntax highlighting assets are in `app/assets/highlight.min.js` and `app/assets/stylesheets/highlight/`.

### Pagination

Kaminari is used — `index` actions paginate with `.page(params[:page])`. Public posts: 9 per page; dashboard: 15 per page.
