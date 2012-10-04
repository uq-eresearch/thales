class AuthoritiesController < ApplicationController
  # GET /authorities
  # GET /authorities.json
  def index
    @authorities = Authority.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @authorities }
    end
  end

  # GET /authorities/1
  # GET /authorities/1.json
  def show
    @authority = Authority.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @authority }
    end
  end

  # GET /authorities/new
  # GET /authorities/new.json
  def new
    @authority = Authority.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @authority }
    end
  end

  # GET /authorities/1/edit
  def edit
    @authority = Authority.find(params[:id])
  end

  # POST /authorities
  # POST /authorities.json
  def create
    @authority = Authority.new(params[:authority])

    respond_to do |format|
      if @authority.save
        format.html { redirect_to @authority, notice: 'Authority was successfully created.' }
        format.json { render json: @authority, status: :created, location: @authority }
      else
        format.html { render action: "new" }
        format.json { render json: @authority.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /authorities/1
  # PUT /authorities/1.json
  def update
    @authority = Authority.find(params[:id])

    respond_to do |format|
      if @authority.update_attributes(params[:authority])
        format.html { redirect_to @authority, notice: 'Authority was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @authority.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authorities/1
  # DELETE /authorities/1.json
  def destroy
    @authority = Authority.find(params[:id])
    @authority.destroy

    respond_to do |format|
      format.html { redirect_to authorities_url }
      format.json { head :no_content }
    end
  end
end
