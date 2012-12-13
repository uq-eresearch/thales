
require 'securerandom'

require 'thales/authentication/password'

class UsersController < ApplicationController

  before_filter :authenticate

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    fix_password_params(params)
    @user = User.new(params[:user])
    @user.uuid = "urn:uuid:#{SecureRandom.uuid}"
    set_roles(@user, params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    fix_password_params(params)
    @user = User.find(params[:id])
    set_roles(@user, params)

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
  def fix_password_params(params)

    pass = params['user']['auth_value']
    conf = params['user']['auth_value_confirmation']

    if pass.blank? && conf.blank?
      # Both fields are blank, delete parameters so password is not changed
      params['user'].delete('auth_value')
      params['user'].delete('auth_value_confirmation')
    else
      # One-way-hash the values
      params['user']['auth_type'] = Thales::Authentication::Password::AUTH_TYPE

      iterations = Thales::Authentication::Password::DEFAULT_ITERATIONS
      salt = Thales::Authentication::Password.salt_generate()

      params['user']['auth_value'] =
        Thales::Authentication::Password.encode(iterations, salt, pass)
      params['user']['auth_value_confirmation'] =
        Thales::Authentication::Password.encode(iterations, salt, conf)
    end
  end

  private
  def set_roles(user, params)
    if ! params['role'].nil?
      user.roles = Role.find(params['role'])
    else
      user.roles.clear
    end
  end

end
