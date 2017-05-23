class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :make_friendship, :accept_friendship, :decline_friendship, :remove_friendship] 

  # GET /users
  # GET /users.json
  def index
    @users = User.all
    @users_requested = current_user.requested_friends
    @users_pending = current_user.pending_friends
    @users_friends = current_user.friends
    @users_become = User.where.not(id: [current_user.id, current_user.friends, current_user.pending_friends, current_user.requested_friends]) 
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  def make_friendship
    current_user.friend_request(@user) 
 end

def accept_friendship
    @user.accept_request(current_user)
end

def decline_friendship
  @user.decline_request(current_user) 
end

def remove_friendship
  @user.remove_friend(current_user)
end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.fetch(:user, {})
    end
end
