
require 'uuid'
require 'record'
#require 'thales/datamodel/e_research'

class RecordsController < ApplicationController

  SER_TYPE_COLLECTION = 1
  
  before_filter :authenticate

  # GET /records
  # GET /records.json
  def index

    @records = Record.all

    @entries = @records.map do |rec|
      c = Thales::Datamodel::EResearch::Collection.new.deserialize(rec.ser_data)
      [ rec, c ]
    end
  
#   @entries.sort! { |a,b| a[1].title <=> b[1].title }
#   @entries.sort! { |a,b| b[0].uuid <=> a[0].uuid }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @records }
    end
  end

  # GET /records/1
  # GET /records/1.json
  def show

    @record = Record.find(params[:id])
    @data = Thales::Datamodel::EResearch::Collection.new.deserialize(@record.ser_data)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @collection }
    end
  end

  # GET /records/new
  # GET /records/new.json
  def new
    @record = Record.new
    @data = Thales::Datamodel::EResearch::Collection.new
#    @data = Thales::Datamodel::EResearch::Party.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @record }
    end
  end

  # GET /records/1/edit
  def edit
    @record = Record.find(params[:id])
    @data = Thales::Datamodel::EResearch::Collection.new.deserialize(@record.ser_data)
  end

  # POST /records
  # POST /records.json
  def create

    @record = Record.new(params[:record])
    @record.uuid = UUID.new.generate(:compact)
    @record.ser_type = SER_TYPE_COLLECTION

    collection = Thales::Datamodel::EResearch::Collection.new(params[:collection])
    @record.ser_data = collection.serialize

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
    # @record.ser_type = SER_TYPE_COLLECTION

    collection = Thales::Datamodel::EResearch::Collection.new(params[:collection])
    @record.ser_data = collection.serialize

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
