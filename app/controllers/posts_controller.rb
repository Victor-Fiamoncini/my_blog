class PostsController < ApplicationController
  def index
    @posts = Post.published.order(published_at: :desc).page(params[:page]).per(9)
  end

  def show
    @post = Post.published.find_by!(slug: params[:slug])
  end
end
