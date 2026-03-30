require "application_system_test_case"

module Dashboard
  class PostsTest < ApplicationSystemTestCase
    setup do
      @user = users(:admin)
    end

    # Login flow (UI-tested here — all other tests use the backdoor helper)
    test "can log in and reach dashboard" do
      visit login_url
      fill_in "email", with: @user.email
      fill_in "password", with: "password1234"
      click_on "Sign In"
      assert_current_path dashboard_root_path
    end

    test "shows error on invalid login" do
      visit login_url
      fill_in "email", with: @user.email
      fill_in "password", with: "wrong"
      click_on "Sign In"
      assert_text(/do not match/i)
    end

    test "can log out" do
      login
      find("button", text: /logout/i).click
      assert_current_path root_path
    end

    # Dashboard index
    test "dashboard lists all posts" do
      login
      assert_text(/my published post/i)
      assert_text(/my draft post/i)
    end

    # Create post
    test "can create a draft post" do
      login
      click_on "+ New Post"

      fill_in "post[title]", with: "A Brand New Post"
      fill_in "post[excerpt]", with: "Short description here."
      set_editor_content("Content written in markdown.")

      click_on "Save Post"

      assert_text(/post created successfully/i)
      assert_field "post[title]", with: "A Brand New Post"
    end

    test "can create and publish a post immediately" do
      login
      click_on "+ New Post"

      fill_in "post[title]", with: "Published Right Away"
      set_editor_content("Published content.")
      check "post[is_published]"

      click_on "Save Post"

      assert_text(/post created successfully/i)
      # Sidebar shows the published date when is_published is true
      assert_selector "input#post_is_published[checked]"
    end

    test "shows validation errors when creating post without title" do
      login
      click_on "+ New Post"

      set_editor_content("Some content")
      click_on "Save Post"

      assert_text(/can't be blank/i)
    end

    # Edit post
    test "can edit an existing post" do
      login
      within("tr", text: /my published post/i) { click_on "Edit" }

      fill_in "post[title]", with: "Updated Post Title"
      click_on "Update Post"

      assert_text(/post updated successfully/i)
      assert_field "post[title]", with: "Updated Post Title"
    end

    test "can publish a draft post from the edit page" do
      login
      within("tr", text: /my draft post/i) { click_on "Edit" }

      # Ensure the checkbox is unchecked first, then check it
      uncheck "post[is_published]" rescue nil
      check "post[is_published]"
      click_on "Update Post"

      assert_text(/post updated successfully/i)
      assert_selector "input#post_is_published[checked]"
    end

    test "shows validation errors when updating with blank title" do
      login
      within("tr", text: /my published post/i) { click_on "Edit" }

      fill_in "post[title]", with: ""
      click_on "Update Post"

      assert_text(/can't be blank/i)
    end

    # Delete post
    test "can delete a post from the dashboard" do
      login
      accept_confirm do
        within("tr", text: /my draft post/i) do
          find("button", text: /delete/i).click
        end
      end

      assert_text(/post deleted successfully/i)
      assert_no_text(/my draft post/i)
    end

    # Toggle published (verify via UI state change)
    test "can toggle status from the index" do
      login

      # Find the first toggle button and note its current label, then toggle it
      button = first("td button")
      original_text = button.text.strip
      button.click

      # After toggle the button label should have changed to the opposite state
      expected_text = original_text.match?(/published/i) ? /draft/i : /published/i
      assert_selector "td button", text: expected_text
    end

    private

    # Bypasses the login UI to avoid DB connection-sharing issues between the test
    # thread and the Puma server thread. Navigates to the dashboard afterwards.
    def login
      visit test_login_url(@user)
      visit dashboard_root_path
    end

    def set_editor_content(text)
      # Wait for EasyMDE to initialize (turbo:load fires after document.readyState=complete,
      # so Capybara may proceed before the editor is ready).
      if has_css?(".EasyMDEContainer", wait: 5)
        page.execute_script("window._easyMDEInstance.value(arguments[0])", text)
      else
        # EasyMDE unavailable (e.g. CDN blocked) — set the raw textarea value directly.
        page.execute_script("document.getElementById('content-editor').value = arguments[0]", text)
      end
    end
  end
end
