class UsersController < ApplicationController
  before_action :load_user, only: :show
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy)
  skip_before_action :verify_authenticity_token


  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find_by id: params[:id]
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)  # Not the final implementation!
    if @user.save
      @user.send_activation_email
      flash[:info] = t(:info)
      redirect_to home_url
    else
      render :new
    end
  end

  def edit 
    @user = User.find_by id: params[:id]
  end

  def update
    @user = User.find_by(id: params[:id])
    if @user.update(user_params)
      flash[:success] = t(:profile_updated)
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    user = User.find_by(id: params[:id])
    if user&.destroy
      flash[:success] = t(:user_deleted)
    else
      flash[:danger] = t(:delete_fail)
    end
    redirect_to users_url
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t(:pls_log_in)
      redirect_to login_url
    end
  end

  def following
    @title = "Following"
    @user = User.find_by(id: params[:id])
    @users = @user.following.paginate(page: params[:page])
    render "show_follow"
  end

  def followers
    @title = "Followers"
    @user = User.find_by(id: params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render "show_follow"
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:error] = t(:error)
    redirect_to root_path
  end

  def correct_user
    @user = User.find_by(id: params[:id])
    return if current_user?(@user)
    flash[:danger] = t(:n_authorized)
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
