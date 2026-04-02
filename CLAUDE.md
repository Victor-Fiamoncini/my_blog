# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

Ruby on Rails 8.1, SQLite3, Tailwind CSS, Hotwire (Turbo + Stimulus), Propshaft, import maps.

## Database

SQLite3 is used for all environments. Database files are stored in `storage/`:

- `storage/development.sqlite3`
- `storage/test.sqlite3`
- `storage/production.sqlite3` (+ cache/queue/cable variants)

No external database server needed. The connection pool size is tied to `RAILS_MAX_THREADS` (default 5), and a `timeout` of 5000ms is set.

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

Two distinct areas with separate layouts (`application.html.erb` vs `dashboard.html.erb`):

- **Public** (`PostsController`): read-only, shows only published posts, routed by slug (`posts/:slug`)
- **Admin** (`Dashboard::PostsController`): full CRUD, requires login via `before_action :require_login`
- **Auth** (`SessionsController`): session-based login with `has_secure_password`

`current_user`, `logged_in?`, and `require_login` are defined on `ApplicationController`. Any authenticated user is an admin — there's no roles system.

### Post publishing model

Posts have two fields controlling visibility: `is_published` (boolean) and `published_at` (datetime). The public scope requires **both**: `is_published = true` AND `published_at` in the past. This enables scheduling future posts.

`Dashboard::PostsController` manages `published_at` automatically:
- First publish → sets `published_at = Time.current`
- Edit while published → preserves original `published_at`
- Unpublish → clears `published_at`

A `toggle_published` member action (`PATCH /dashboard/posts/:id/toggle_published`) provides a quick publish/unpublish toggle from the index list.

### Slug generation

`Post` auto-generates a slug from the title on creation (before_validation). Special characters are stripped, spaces become hyphens. Collisions are resolved by appending `-1`, `-2`, etc. Manually setting a slug before save skips auto-generation.

### Markdown rendering

`ApplicationHelper#markdown(text)` renders post content using Redcarpet with autolink, tables, fenced code blocks, strikethrough, and superscript. Links open in a new tab (`target="_blank"`). This helper is used in post views; the admin editor uses EasyMDE (a client-side Markdown editor loaded via import map from CDN).

### Test helpers

A test-only route exists at `/test/login/:user_id` (conditionally defined in `config/routes.rb`) to bypass the password dance in tests. System tests that interact with the EasyMDE editor use a `set_editor_content()` helper to drive the CodeMirror instance via JavaScript.

Test fixtures cover three post states: published (past `published_at`), draft (`is_published = false`, no date), and future-scheduled (future `published_at`).

### JavaScript

Import maps (`config/importmap.rb`) pin Turbo, Stimulus, Highlight.js, and EasyMDE from CDN. Local JS lives in `app/javascript/`. Syntax highlighting assets are in `app/assets/highlight.min.js` and `app/assets/stylesheets/highlight/`.

### Pagination

Kaminari is used — `index` actions paginate with `.page(params[:page])`. Public posts: 9 per page; dashboard: 15 per page.
