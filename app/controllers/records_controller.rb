
require 'securerandom'
require 'record'

# Ruby on Rails controller

class RecordsController < ApplicationController

  before_filter :authenticate

  # GET /records
  # GET /records.json
  def index

    @query = params[:q]
    if @query
      @query.lstrip!
      @query.rstrip!
      @query.downcase!
      if @query == ''
        @query = nil
      end
    end

    if @query
      # Search requested

      # TODO: replace this very inefficient placeholder
      @records = Record.all.keep_if do |record|
        match = false
        r_class = Thales::Datamodel::CLASS_FOR[record.ser_type]
        data = r_class.new.deserialize(record.ser_data)
        data.title.each do |value|
          value.downcase!
          if value.include?(@query)
            match = true
            break
          end
        end
        match
      end

    else
      # All
      @records = Record.all
    end


    @entries = @records.map do |record|
      r_class = Thales::Datamodel::CLASS_FOR[record.ser_type]
      [ record, r_class.new.deserialize(record.ser_data) ]
    end
  
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @records }
    end
  end

  # GET /records/1
  # GET /records/1.json

  def show

    @record = Record.find(params[:id])

    r_class = Thales::Datamodel::CLASS_FOR[@record.ser_type]
    @data = r_class.new.deserialize(@record.ser_data)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @data }
      format.xml { send_data @data.serialize }
      format.rifcs { send_data @data.to_rifcs }
    end
  end

  NEW_TYPE = {
    'collection' => Thales::Datamodel::E_RESEARCH_COLLECTION,
    'party' => Thales::Datamodel::E_RESEARCH_PARTY,
    'activity' => Thales::Datamodel::E_RESEARCH_ACTIVITY,
    'service' => Thales::Datamodel::E_RESEARCH_SERVICE,
  }

  # GET /records/new
  # GET /records/new.json
  def new
    @record = Record.new

    @record.ser_type = NEW_TYPE[params[:type]]
    s_class = Thales::Datamodel::CLASS_FOR[@record.ser_type]
    if s_class.nil?
      s_class = Thales::Datamodel::EResearch::Collection # default
    end
    @data = s_class.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @record }
    end
  end

  # GET /records/1/edit
  def edit
    @record = Record.find(params[:id])

    r_class = Thales::Datamodel::CLASS_FOR[@record.ser_type]
    @data = r_class.new.deserialize(@record.ser_data)
  end

  # POST /records
  # POST /records.json
  def create

    @record = Record.new(params[:record])
    @record.uuid = "urn:uuid:#{SecureRandom.uuid}"

    r_class = Thales::Datamodel::CLASS_FOR[@record.ser_type]
    data = r_class.new(params[:data])
    @record.ser_data = data.serialize

    if @record.save
      redirect_to @record, notice: 'Record was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /records/1
  # PUT /records/1.json
  def update
    @record = Record.find(params[:id])

    r_class = Thales::Datamodel::CLASS_FOR[@record.ser_type]
    @record.ser_data = r_class.new(params[:data]).serialize

    respond_to do |format|
      if @record.update_attributes(params[:record])
        format.html { redirect_to @record, notice: 'Record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /records/1
  # DELETE /records/1.json
  def destroy
    @record = Record.find(params[:id])
    @record.destroy

    respond_to do |format|
      format.html { redirect_to records_url }
      format.json { head :no_content }
    end
  end

end
