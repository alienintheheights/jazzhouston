class UsersController < ApplicationController
  #before_filter :authenticate_user!
  #include DeviseHelper


  def index
    #authorize User
    @users = User.all || []
    respond_to do |format|
    format.html
    format.json { render json: @users }
  end
  end


  def show
    @user = User.find(params[:id])
  end

  def new
     @user.pictures.build
  end


  def edit
   # @user.pictures.build if @user.pictures.empty?
  end

  def update
    authorize User

    @user = User.find(params[:id])

    if @user.update(safe_params)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end


  def destroy
    user = User.find(params[:id])
    if user != current_user
      user.destroy
      redirect_to users_path, :notice => "User deleted."
    else
      redirect_to users_path, :notice => "Can't delete yourself."
    end
  end

  private

  def safe_params
    params.require(:user).permit(*policy(@user || User).permitted_attributes)
  end


end