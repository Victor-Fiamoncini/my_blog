class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found
    render "errors/not_found", status: :not_found, layout: "application"
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    redirect_to login_path, alert: "You must be logged in." unless logged_in?
  end
end
