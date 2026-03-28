return unless Rails.env.test?

module Test
  class SessionsController < ApplicationController
    def create
      session[:user_id] = params[:user_id].to_i
      head :ok
    end
  end
end
