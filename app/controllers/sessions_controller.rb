class SessionsController < ApplicationController
  def new
    redirect_to dashboard_root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to dashboard_root_path
    else
      flash.now[:alert] = "These credentials do not match our records."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path
  end
end
