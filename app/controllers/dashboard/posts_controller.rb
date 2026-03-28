module Dashboard
  class PostsController < ApplicationController
    layout "dashboard"
    before_action :require_login
    before_action :set_post, only: [ :edit, :update, :destroy, :toggle_published ]

    def index
      @posts = Post.order(created_at: :desc).page(params[:page]).per(15)
    end

    def new
      @post = Post.new
    end

    def create
      @post = Post.new(post_params)
      @post.published_at = Time.current if post_params[:is_published] == "1"
      if @post.save
        flash[:success] = "Post created successfully."
        redirect_to edit_dashboard_post_path(@post)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      published_at = @post.published_at
      will_publish = post_params[:is_published] == "1"

      if will_publish && !@post.is_published?
        published_at = Time.current
      elsif !will_publish
        published_at = nil
      end

      if @post.update(post_params.merge(published_at: published_at))
        flash[:success] = "Post updated successfully."
        redirect_to edit_dashboard_post_path(@post)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def toggle_published
      if @post.is_published?
        @post.update!(is_published: false, published_at: nil)
      else
        @post.update!(is_published: true, published_at: Time.current)
      end
      redirect_to dashboard_root_path
    end

    def destroy
      @post.destroy
      flash[:success] = "Post deleted successfully."
      redirect_to dashboard_root_path
    end

    private

    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :excerpt, :content, :is_published)
    end
  end
end
